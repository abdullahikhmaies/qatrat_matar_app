import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();
  UserModel? _scannedCustomer;
  bool _isProcessing = false;
  double _litersToFill = 19.0;
  double _currentPricePerLiter = 0.026;
  StreamSubscription? _settingsSubscription;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _settingsSubscription?.cancel();
    super.dispose();
  }

  void _loadSettings() {
    _settingsSubscription = _dbService.getAppSettings().listen((snapshot) {
      if (snapshot.exists && mounted) {
        setState(() {
          _currentPricePerLiter = snapshot.get('price_per_liter')?.toDouble() ?? 0.026;
        });
      }
    });
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_scannedCustomer != null || _isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() => _isProcessing = true);
        UserModel? customer = await _dbService.getUserById(barcode.rawValue!);
        setState(() {
          _scannedCustomer = customer;
          _isProcessing = false;
        });
        if (customer == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('عذراً، لم يتم العثور على العميل')));
        }
        break;
      }
    }
  }

  void _processRefill() async {
    if (_scannedCustomer == null) return;
    setState(() => _isProcessing = true);
    
    double totalAmount = _litersToFill * _currentPricePerLiter;
    String currentStaffId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

    TransactionModel transaction = TransactionModel(
      id: "REF_${DateTime.now().millisecondsSinceEpoch}",
      customerId: _scannedCustomer!.id,
      staffId: currentStaffId,
      amount: totalAmount,
      liters: _litersToFill,
      timestamp: DateTime.now(),
      type: 'refill',
    );

    try {
      await _dbService.addTransaction(transaction);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تمت العملية بنجاح'),
          content: Text('تم تعبئة $_litersToFill لتر وخصم ${totalAmount.toStringAsFixed(3)} د.أ'),
          actions: [
            TextButton(onPressed: () {
              Navigator.pop(context);
              if (mounted) setState(() => _scannedCustomer = null);
            }, child: const Text('موافق')),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _redeemPoints() async {
    if (_scannedCustomer == null) return;
    int pointsNeeded = (_litersToFill * 10).toInt(); // مثلاً 10 نقاط لكل لتر
    
    if (_scannedCustomer!.points < pointsNeeded) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('النقاط غير كافية. يحتاج العميل لـ $pointsNeeded نقطة')));
      return;
    }

    setState(() => _isProcessing = true);
    try {
      await _dbService.redeemPoints(
        _scannedCustomer!.id, 
        _litersToFill, 
        pointsNeeded, 
        FirebaseAuth.instance.currentUser?.uid ?? 'unknown'
      );
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('مكافأة ولاء'),
          content: Text('تمت التعبئة مجانًا مقابل خصم $pointsNeeded نقطة'),
          actions: [
            TextButton(onPressed: () {
              Navigator.pop(context);
              if (mounted) setState(() => _scannedCustomer = null);
            }, child: const Text('ممتاز')),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF1E293B),
        appBar: AppBar(
          backgroundColor: Colors.black.withValues(alpha: 0.8),
          title: const Text('نقطة البيع - موظف التعبئة', style: TextStyle(color: Colors.blue, fontSize: 16)),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.qr_code_scanner), text: 'التعبئة'),
              Tab(icon: Icon(Icons.assignment), text: 'المهام'),
            ],
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.white70,
          ),
          actions: [
            IconButton(onPressed: () {
              _authService.signOut();
              Navigator.pushReplacementNamed(context, '/');
            }, icon: const Icon(Icons.logout, color: Colors.white70)),
          ],
        ),
        body: TabBarView(
          children: [
            _buildRefillTab(),
            _buildTasksTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildRefillTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          if (_scannedCustomer == null)
            Column(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.blue.withValues(alpha: 0.3))),
                    child: ClipRRect(borderRadius: BorderRadius.circular(32), child: MobileScanner(onDetect: _onDetect)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('وجه الكاميرا لمسح رمز QR العميل', style: TextStyle(color: Colors.white70)),
              ],
            )
          else
            _buildCustomerDetails(),
          if (_isProcessing) const Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator(color: Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildTasksTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _dbService.getTasks(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var tasks = snapshot.data!.docs;
        if (tasks.isEmpty) return const Center(child: Text('لا توجد مهام حالية', style: TextStyle(color: Colors.white70)));
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            var task = tasks[index];
            bool isPending = task['status'] == 'pending';
            return Card(
              color: const Color(0xFF0F172A),
              child: ListTile(
                title: Text(task['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(task['description'], style: const TextStyle(color: Colors.white70)),
                trailing: isPending 
                  ? ElevatedButton(
                      onPressed: () => _dbService.updateTaskStatus(task.id, 'completed'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: const Text('إتمام'),
                    )
                  : const Icon(Icons.check_circle, color: Colors.green),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCustomerDetails() {
    double totalCost = _litersToFill * _currentPricePerLiter;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.blue.withValues(alpha: 0.5))),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 30, backgroundColor: Colors.blue.withValues(alpha: 0.1), child: Text(_scannedCustomer!.name[0], style: const TextStyle(fontSize: 24, color: Colors.blue))),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_scannedCustomer!.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('الرصيد: ${_scannedCustomer!.balance.toStringAsFixed(3)} د.أ', style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('نقاط الولاء: ${_scannedCustomer!.points}', style: const TextStyle(color: Colors.amber, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white10),
              const SizedBox(height: 16),
              const Text('حجم التعبئة المطلوب:', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [5.0, 10.0, 19.0].map((val) => ChoiceChip(
                  label: Text('${val.toInt()} لتر'),
                  selected: _litersToFill == val,
                  onSelected: (selected) { if (selected) setState(() => _litersToFill = val); },
                )).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('التكلفة: ${totalCost.toStringAsFixed(3)} د.أ', style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('سعر اللتر: $_currentPricePerLiter', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                    ],
                  ),
                  if (_scannedCustomer!.points >= (_litersToFill * 10))
                    TextButton.icon(
                      onPressed: _isProcessing ? null : _redeemPoints,
                      icon: const Icon(Icons.stars, color: Colors.amber, size: 18),
                      label: const Text('استبدال بالنقاط', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(backgroundColor: Colors.amber.withValues(alpha: 0.1)),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity, height: 60,
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _processRefill,
            icon: const Icon(Icons.water_drop),
            label: const Text('تأكيد التعبئة والخصم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
          ),
        ),
        TextButton(onPressed: () => setState(() => _scannedCustomer = null), child: const Text('إلغاء', style: TextStyle(color: Colors.white54))),
      ],
    );
  }
}
