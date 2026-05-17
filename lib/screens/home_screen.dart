import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';
import 'history_screen.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final AuthService authService = AuthService();

    // [FIX M-06] إعادة التوجيه لتسجيل الدخول إذا لم تكن الجلسة نشطة
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid) // آمن الآن بعد التحقق من user != null
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text('خطأ في تحميل البيانات')));
        }

        UserModel userData = UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: Colors.white.withValues(alpha: 0.8),
            elevation: 0,
            title: Row(
              children: [
                const Icon(Icons.water_drop, color: AppTheme.primary),
                const SizedBox(width: 12),
                Text('قطرة مطر', style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  await authService.signOut();
                  if (context.mounted) Navigator.pushReplacementNamed(context, '/');
                },
                icon: const Icon(Icons.logout, color: Colors.red),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // QR Code Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)],
                  ),
                  child: Column(
                    children: [
                      const Text('الرمز الخاص بي للتعبئة', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      QrImageView(
                        data: userData.id,
                        version: QrVersions.auto,
                        size: 200.0,
                        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppTheme.primary),
                        dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppTheme.primary),
                      ),
                      const SizedBox(height: 12),
                      Text('رقم الهاتف المسجل', style: Theme.of(context).textTheme.labelSmall),
                      Text(userData.phone, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Wallet Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('الرصيد الحالي', style: TextStyle(color: Colors.white70)),
                              Text('${userData.balance.toStringAsFixed(3)} د.أ', 
                                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(15)),
                            child: Column(
                              children: [
                                const Icon(Icons.stars, color: Colors.amber, size: 20),
                                Text('${userData.points}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Action Cards
                _buildActionCard(context, Icons.history, 'سجل العمليات', 'تابع تعبئاتك السابقة', () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, String title, String sub, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 30),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
