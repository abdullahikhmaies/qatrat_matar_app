import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import '../services/pdf_service.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();
  int _selectedMenuIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Controllers for Top-up section
  final TextEditingController _topUpPhoneController = TextEditingController();
  final TextEditingController _topUpAmountController = TextEditingController();
  UserModel? _foundCustomer;
  bool _isSearching = false;

  // Controller for Settings
  final TextEditingController _priceController = TextEditingController();

  @override
  void dispose() {
    _topUpPhoneController.dispose();
    _topUpAmountController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 900;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppTheme.background,
        appBar: isMobile
            ? AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                title: const Text('قطرة مطر - الإدارة', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                leading: IconButton(
                  icon: const Icon(Icons.menu, color: AppTheme.primary),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              )
            : null,
        drawer: isMobile ? Drawer(child: _buildSidebarContents()) : null,
        body: Row(
          children: [
            if (!isMobile) _buildSidebar(),
            Expanded(child: _buildMainContent(isMobile)),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() => Container(width: 280, color: Colors.white, child: _buildSidebarContents());

  Widget _buildSidebarContents() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              const Icon(Icons.water_drop, color: AppTheme.primary, size: 30),
              const SizedBox(width: 12),
              const Text('قطرة مطر', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary)),
            ],
          ),
        ),
        const SizedBox(height: 40),
        _buildMenuItem(0, Icons.grid_view_rounded, 'لوحة القيادة'),
        _buildMenuItem(1, Icons.account_balance_wallet_rounded, 'شحن الرصيد'),
        _buildMenuItem(2, Icons.people_alt_rounded, 'الموظفين'),
        _buildMenuItem(4, Icons.storage_rounded, 'إدارة المخزون'),
        _buildMenuItem(5, Icons.assignment_rounded, 'المهام'),
        _buildMenuItem(3, Icons.settings_rounded, 'الإعدادات'),
        const Spacer(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.redAccent),
          title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.redAccent)),
          onTap: () async {
            final nav = Navigator.of(context);
            await _authService.signOut();
            nav.pushReplacementNamed('/');
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String title) {
    bool isSelected = _selectedMenuIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedMenuIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primary : Colors.grey[400]),
            const SizedBox(width: 16),
            Text(title, style: TextStyle(color: isSelected ? AppTheme.primary : Colors.grey[600], fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isMobile) {
    switch (_selectedMenuIndex) {
      case 0: return _buildDashboard(isMobile);
      case 1: return _buildTopUpSection(isMobile);
      case 2: return _buildStaffManagement(isMobile);
      case 3: return _buildSettingsSection(isMobile);
      case 4: return _buildInventorySection(isMobile);
      case 5: return _buildTasksSection(isMobile);
      default: return const Center(child: Text('قيد التطوير'));
    }
  }

  Widget _buildStaffManagement(bool isMobile) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('إدارة الموظفين', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _showAddStaffDialog(),
                icon: const Icon(Icons.add),
                label: const Text('إضافة موظف'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: _authService.getStaffList(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var staff = snapshot.data!;
                return ListView.builder(
                  itemCount: staff.length,
                  itemBuilder: (context, index) {
                    var s = staff[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.badge_outlined)),
                        title: Text(s.name),
                        subtitle: Text(s.phone),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                              onPressed: () => _showEditStaffDialog(s),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _dbService.deleteStaff(s.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditStaffDialog(UserModel staff) {
    final nameC = TextEditingController(text: staff.name);
    final phoneC = TextEditingController(text: staff.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل بيانات: ${staff.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameC, decoration: const InputDecoration(labelText: 'الاسم الجديد')),
            const SizedBox(height: 16),
            TextField(controller: phoneC, decoration: const InputDecoration(labelText: 'رقم الهاتف الجديد')),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await _authService.sendPasswordReset(staff.email);
                messenger.showSnackBar(const SnackBar(content: Text('تم إرسال رابط تعيين كلمة المرور لبريد الموظف')));
              },
              icon: const Icon(Icons.lock_reset, size: 18),
              label: const Text('إرسال رابط إعادة تعيين كلمة المرور'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                final nav = Navigator.of(context);
                await _authService.updateStaffProfile(
                  uid: staff.id,
                  name: nameC.text,
                  phone: phoneC.text,
                );
                nav.pop();
              },
            child: const Text('حفظ التعديلات'),
          ),
        ],
      ),
    ).then((_) {
      nameC.dispose();
      phoneC.dispose();
    });
  }

  void _showAddStaffDialog() {
    final nameC = TextEditingController();
    final phoneC = TextEditingController();
    final passC = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة موظف جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameC, decoration: const InputDecoration(labelText: 'الاسم')),
            TextField(controller: phoneC, decoration: const InputDecoration(labelText: 'رقم الهاتف')),
            TextField(controller: passC, decoration: const InputDecoration(labelText: 'كلمة المرور')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                final nav = Navigator.of(context);
                String normalizedPhone = DatabaseService.normalizePhone(phoneC.text);
                await _authService.addStaffByAdmin(
                  email: "$normalizedPhone@raindrop.jo",
                  password: passC.text,
                  name: nameC.text,
                  phone: normalizedPhone
                );
                nav.pop();
              },
            child: const Text('إضافة'),
          ),
        ],
      ),
    ).then((_) {
      nameC.dispose();
      phoneC.dispose();
      passC.dispose();
    });
  }

  Widget _buildDashboard(bool isMobile) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _dbService.getAdminStats(),
      builder: (context, snapshot) {
        var stats = snapshot.data ?? {'totalSales': 0.0, 'totalLiters': 0.0, 'transactions': 0};
        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('لوحة التحكم الحقيقية', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                  StreamBuilder<List<TransactionModel>>(
                    stream: _dbService.getAllTransactions(),
                    builder: (context, txSnapshot) {
                      return ElevatedButton.icon(
                        onPressed: () => txSnapshot.hasData ? PdfService.generateSalesReport(txSnapshot.data!) : null,
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('تصدير تقرير المبيعات'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                      );
                    }
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16, runSpacing: 16,
                children: [
                  _buildStatsCard('إجمالي المبيعات', 'JOD ${stats['totalSales'].toStringAsFixed(2)}', 'منذ بداية المشروع', Icons.payments, Colors.blue, isMobile),
                  _buildStatsCard('إجمالي المياه', '${stats['totalLiters'].toStringAsFixed(0)} لتر', 'إجمالي الكمية المباعة', Icons.opacity, Colors.cyan, isMobile),
                  _buildStatsCard('عدد العمليات', '${stats['transactions']}', 'عمليات تعبئة ناجحة', Icons.receipt_long, Colors.indigo, isMobile),
                ],
              ),
              const SizedBox(height: 40),
              const Text('آخر العمليات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTransactionsList(),
            ],
          ),
        );
      }
    );
  }

  Widget _buildTopUpSection(bool isMobile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('شحن رصيد العملاء', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                TextField(
                  controller: _topUpPhoneController,
                  decoration: InputDecoration(
                    labelText: 'رقم هاتف العميل',
                    suffixIcon: IconButton(
                      icon: _isSearching ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.search),
                      onPressed: () async {
                        setState(() => _isSearching = true);
                        var user = await _dbService.getUserByPhone(_topUpPhoneController.text);
                        if (!mounted) return;
                        setState(() {
                          _foundCustomer = user;
                          _isSearching = false;
                        });
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('العميل غير موجود')));
                        }
                      },
                    ),
                  ),
                ),
                if (_foundCustomer != null) ...[
                  const SizedBox(height: 24),
                  ListTile(
                    tileColor: Colors.blue.withValues(alpha: 0.05),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    title: Text(_foundCustomer!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('الرصيد الحالي: ${_foundCustomer!.balance} د.أ'),
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _topUpAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'قيمة الشحن (د.أ)'),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        double? amount = double.tryParse(_topUpAmountController.text);
                        if (amount == null || amount <= 0) return;
                        
                        final messenger = ScaffoldMessenger.of(context);
                        
                        await _dbService.topUpBalance(
                          _foundCustomer!.id, 
                          amount, 
                          FirebaseAuth.instance.currentUser!.uid
                        );
                        
                        messenger.showSnackBar(const SnackBar(content: Text('تم شحن الرصيد بنجاح')));
                        _topUpPhoneController.clear();
                        _topUpAmountController.clear();
                        setState(() => _foundCustomer = null);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                      child: const Text('تأكيد الشحن'),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(bool isMobile) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _dbService.getAppSettings(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          double price = snapshot.data!.get('price_per_liter')?.toDouble() ?? 0.026;
          if (_priceController.text.isEmpty) {
            _priceController.text = price.toString();
          }
        }

        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('إعدادات النظام', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    TextField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'سعر لتر الماء (د.أ)', suffixText: 'د.أ / لتر'),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          double? p = double.tryParse(_priceController.text);
                          if (p != null) {
                            final messenger = ScaffoldMessenger.of(context);
                            await _dbService.updatePrice(p);
                            messenger.showSnackBar(const SnackBar(content: Text('تم تحديث السعر بنجاح')));
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        child: const Text('حفظ الإعدادات'),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text('اللغة / Language', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => QatratMatarApp.setLocale(context, const Locale('ar', 'SA')),
                          style: ElevatedButton.styleFrom(backgroundColor: Localizations.localeOf(context).languageCode == 'ar' ? AppTheme.primary : Colors.grey[200]),
                          child: const Text('العربية'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () => QatratMatarApp.setLocale(context, const Locale('en', 'US')),
                          style: ElevatedButton.styleFrom(backgroundColor: Localizations.localeOf(context).languageCode == 'en' ? AppTheme.primary : Colors.grey[200]),
                          child: const Text('English'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildTransactionsList() {
    return StreamBuilder<List<TransactionModel>>(
      stream: _dbService.getAllTransactions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            var tx = snapshot.data![index];
            bool isRefill = tx.type == 'refill';
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isRefill ? Colors.blue.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                  child: Icon(isRefill ? Icons.opacity : Icons.add_card, color: isRefill ? Colors.blue : Colors.green),
                ),
                title: Text(isRefill ? 'تعبئة مياه (${tx.liters} لتر)' : 'شحن رصيد محفظة'),
                subtitle: Text(tx.timestamp.toString().substring(0, 16)),
                trailing: Text('${tx.amount.toStringAsFixed(3)} د.أ', style: TextStyle(fontWeight: FontWeight.bold, color: isRefill ? Colors.red : Colors.green)),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatsCard(String title, String value, String subtitle, IconData icon, Color color, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 260,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildInventorySection(bool isMobile) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _dbService.getInventoryStatus(),
      builder: (context, snapshot) {
        double currentLiters = snapshot.data?.exists == true ? (snapshot.data!.get('current_liters') ?? 5000.0).toDouble() : 5000.0;
        double percentage = (currentLiters / 5000.0).clamp(0, 1);
        
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('مراقبة المخزون - الخزان الرئيسي', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          width: 150, height: 250,
                          decoration: BoxDecoration(border: Border.all(color: AppTheme.primary, width: 4), borderRadius: BorderRadius.circular(20)),
                        ),
                        AnimatedContainer(
                          duration: const Duration(seconds: 1),
                          width: 142, height: 242 * percentage,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.only(bottomLeft: const Radius.circular(16), bottomRight: const Radius.circular(16), 
                            topLeft: Radius.circular(percentage > 0.95 ? 16 : 0), topRight: Radius.circular(percentage > 0.95 ? 16 : 0)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('${currentLiters.toInt()} / 5000 لتر', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    Text('النسبة الحالية: ${(percentage * 100).toInt()}%', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 32),
                    if (percentage < 0.2)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [Icon(Icons.warning, color: Colors.red), SizedBox(width: 8), Text('تحذير: مستوى المياه منخفض جداً', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))],
                        ),
                      ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => _dbService.refillInventory(5000 - currentLiters),
                      icon: const Icon(Icons.local_shipping),
                      label: const Text('إعادة تعبئة الخزان بالكامل'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  void _showAddTaskDialog() {
    final titleC = TextEditingController();
    final descC = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة مهمة جديدة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleC, decoration: const InputDecoration(labelText: 'عنوان المهمة')),
            TextField(controller: descC, decoration: const InputDecoration(labelText: 'التفاصيل')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () { _dbService.createTask(titleC.text, descC.text); Navigator.pop(context); }, child: const Text('إرسال')),
        ],
      ),
    ).then((_) {
      titleC.dispose();
      descC.dispose();
    });
  }

  Widget _buildTasksSection(bool isMobile) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('إدارة مهام الموظفين', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: _showAddTaskDialog,
                icon: const Icon(Icons.add_task),
                label: const Text('إرسال مهمة'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _dbService.getTasks(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var task = snapshot.data!.docs[index];
                    bool isPending = task['status'] == 'pending';
                    return Card(
                      child: ListTile(
                        leading: Icon(isPending ? Icons.pending_actions : Icons.check_circle, color: isPending ? Colors.orange : Colors.green),
                        title: Text(task['title']),
                        subtitle: Text(task['description']),
                        trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _dbService.deleteTask(task.id)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
