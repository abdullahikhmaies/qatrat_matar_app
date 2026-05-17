import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'employee_screen.dart';
import 'admin_screen.dart';
import '../theme.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primary, AppTheme.secondary],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCYQijQTU3DayqVgM0lk09Q4hTTgs2hYRNnF_iZeJqPC-2ohBsFikDL4TLeOH9fkKkVnuUFI1_ExtqV_GSHrSb51sps9hu4vU2hMZbJ4Hc72hbnnUrnhMAWT6JER4GWx7lUiiY2xmCTNjvNyKa6_bH6cM0Robn6_0bNsvF3MciAlnJ4owDyubWLJ5eRMKP92NspL1LWeA4mr705skTGhrb61pMQoIZzVgUEN39_SDJxSQzECURvzOfW-3AUSF2tQ-hVixuvO3NU9dY',
              height: 120,
            ),
            const SizedBox(height: 24),
            const Text(
              'قطرة مطر',
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const Text(
              'اختر نوع الحساب للدخول',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 48),
            _buildRoleButton(context, 'حساب العميل', Icons.person, const HomeScreen()),
            const SizedBox(height: 16),
            _buildRoleButton(context, 'لوحة الموظف', Icons.badge, const EmployeeScreen()),
            const SizedBox(height: 16),
            _buildRoleButton(context, 'لوحة المسؤول', Icons.admin_panel_settings, const AdminScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context, String title, IconData icon, Widget screen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
          },
          icon: Icon(icon),
          label: Text(title),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
