import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();
  // [FIX #1] Controller صريح لإغلاق الكاميرا وتحرير native resources
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
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
    _scannerController.dispose(); // [FIX #1] إغلاق الكاميرا وتحرير الذاكرة
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
        if (!mounted) return;
        setState(() => _isProcessing = true);
        final UserModel? customer = await _dbService.getUserById(barcode.rawValue!);
        // [FIX #9] تحقق من mounted بعد كل await قبل استخدام context أو setState
        if (!mounted) return;
        setState(() {
          _scannedCustomer = customer;
          _isProcessing = false;
        });
        if (customer == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('عذراً، لم يتم العثور على العميل')),
          );
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
      child: Stack(
        children: [
          _buildBackground(),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: AppTheme.primary,
              elevation: 0,
              title: const Text('نقطة البيع - موظف التعبئة', style: TextStyle(color: Colors.white, fontSize: 16)),
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.qr_code_scanner), text: 'التعبئة'),
                  Tab(icon: Icon(Icons.assignment), text: 'المهام'),
                ],
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: AppTheme.brandLightBlue,
              ),
              actions: [
                IconButton(onPressed: () {
                  _authService.signOut();
                  Navigator.pushReplacementNamed(context, '/');
                }, icon: const Icon(Icons.logout, color: Colors.white)),
              ],
            ),
            body: TabBarView(
              children: [
                _buildRefillTab(),
                _buildTasksTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: Stack(
        children: [
          // فقاعات زخرفية مستوحاة من الماء
          Positioned(top: -30, right: -20, child: _buildBubble(120, const Color(0x1A1A4D8C))),
          Positioned(top: 80, right: 30, child: _buildBubble(50, const Color(0x151A4D8C))),
          Positioned(top: 60, left: -30, child: _buildBubble(80, const Color(0x101A4D8C))),
          Positioned(bottom: 150, left: -40, child: _buildBubble(140, const Color(0x0A1A4D8C))),
          Positioned(bottom: 80, right: -10, child: _buildBubble(70, const Color(0x121A4D8C))),
        ],
      ),
    );
  }

  Widget _buildBubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1), width: 1),
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
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)), boxShadow: AppTheme.cardShadow),
                    // [FIX #1] ربط الـ controller الصريح بالـ MobileScanner
                child: ClipRRect(borderRadius: BorderRadius.circular(32), child: MobileScanner(controller: _scannerController, onDetect: _onDetect)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('وجه الكاميرا لمسح رمز QR العميل', style: TextStyle(color: AppTheme.primary)),
              ],
            )
          else
            _buildCustomerDetails(),
          if (_isProcessing) const Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator(color: AppTheme.primary)),
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
        if (tasks.isEmpty) return const Center(child: Text('لا توجد مهام حالية', style: TextStyle(color: AppTheme.primary)));
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            var task = tasks[index];
            bool isPending = task['status'] == 'pending';
            return Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFDEE3ED)),
              ),
              child: ListTile(
                title: Text(task['title'], style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                subtitle: Text(task['description'], style: const TextStyle(color: AppTheme.outline)),
                trailing: isPending 
                  ? ElevatedButton(
                      onPressed: () => _dbService.updateTaskStatus(task.id, 'completed'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                      child: const Text('إتمام'),
                    )
                  : const Icon(Icons.check_circle, color: AppTheme.success),
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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)), boxShadow: AppTheme.cardShadow),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 30, backgroundColor: AppTheme.primary.withValues(alpha: 0.1), child: Text(_scannedCustomer!.name[0], style: const TextStyle(fontSize: 24, color: AppTheme.primary))),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_scannedCustomer!.name, style: const TextStyle(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('الرصيد: ${_scannedCustomer!.balance.toStringAsFixed(3)} د.أ', style: const TextStyle(color: AppTheme.success, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('نقاط الولاء: ${_scannedCustomer!.points}', style: const TextStyle(color: AppTheme.warning, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: Color(0xFFDEE3ED)),
              const SizedBox(height: 16),
              const Text('حجم التعبئة المطلوب:', style: TextStyle(color: AppTheme.outline)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [5.0, 10.0, 19.0].map((val) => ChoiceChip(
                  label: Text('${val.toInt()} لتر'),
                  selected: _litersToFill == val,
                  selectedColor: AppTheme.primaryContainer,
                  labelStyle: TextStyle(color: _litersToFill == val ? Colors.white : AppTheme.primary),
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
                       Text('التكلفة: ${totalCost.toStringAsFixed(3)} د.أ', style: const TextStyle(color: AppTheme.warning, fontSize: 16, fontWeight: FontWeight.bold)),
                       Text('سعر اللتر: $_currentPricePerLiter', style: const TextStyle(color: AppTheme.outline, fontSize: 10)),
                     ],
                  ),
                  if (_scannedCustomer!.points >= (_litersToFill * 10))
                    TextButton.icon(
                      onPressed: _isProcessing ? null : _redeemPoints,
                      icon: const Icon(Icons.stars, color: AppTheme.warning, size: 18),
                      label: const Text('استبدال بالنقاط', style: TextStyle(color: AppTheme.warning, fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(backgroundColor: AppTheme.warning.withValues(alpha: 0.1)),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
          ),
        ),
        TextButton(onPressed: () => setState(() => _scannedCustomer = null), child: const Text('إلغاء', style: TextStyle(color: AppTheme.outline))),
      ],
    );
  }
}
