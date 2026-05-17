import 'package:flutter/material.dart';
import '../theme.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // خلفية علوية بتدرج
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A3A6B), Color(0xFF1A4D8C)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
            ),
          ),
          // فقاعات زخرفية
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            top: 80,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                // اللوغو والعنوان
                _buildHeader(context),
                const SizedBox(height: 60),
                // بطاقات الأدوار
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildRoleCard(
                          context,
                          icon: Icons.person_rounded,
                          title: 'حساب العميل',
                          subtitle: 'إدارة رصيدك وتعبئة المياه',
                          color: AppTheme.primary,
                          gradientColors: [const Color(0xFF1A4D8C), const Color(0xFF3BAED6)],
                          screen: const LoginScreen(),
                        ),
                        const SizedBox(height: 16),
                        _buildRoleCard(
                          context,
                          icon: Icons.badge_rounded,
                          title: 'لوحة الموظف',
                          subtitle: 'مسح رموز العملاء وإدارة التعبئة',
                          color: const Color(0xFF0D9488),
                          gradientColors: [const Color(0xFF0D9488), const Color(0xFF14B8A6)],
                          screen: const LoginScreen(),
                        ),
                        const SizedBox(height: 16),
                        _buildRoleCard(
                          context,
                          icon: Icons.admin_panel_settings_rounded,
                          title: 'لوحة المسؤول',
                          subtitle: 'الإحصائيات والتقارير والإدارة الشاملة',
                          color: const Color(0xFF7C3AED),
                          gradientColors: [const Color(0xFF7C3AED), const Color(0xFF9F67FF)],
                          screen: const LoginScreen(),
                        ),
                        const Spacer(),
                        // نص ترحيبي
                        Padding(
                          padding: const EdgeInsets.only(bottom: 32),
                          child: Text(
                            'قطرة مطر للمياه الصحية © 2024',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // اللوغو بخلفية بيضاء
        Container(
          width: 100,
          height: 100,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Image.asset('assets/logo.png', fit: BoxFit.contain),
        ),
        const SizedBox(height: 16),
        const Text(
          'قطرة مطر',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'اختر نوع الحساب للدخول',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required List<Color> gradientColors,
    required Widget screen,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // السهم للتنقل (يمين في RTL)
            Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.grey[300],
              size: 18,
            ),
            const Spacer(),
            // النص
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // الأيقونة
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
          ],
        ),
      ),
    );
  }
}
