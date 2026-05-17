import 'package:flutter/material.dart';
import '../theme.dart';
import 'login_screen.dart';

class VerificationSuccessScreen extends StatelessWidget {
  const VerificationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // خلفية متدرجة مع فقاعات ماء زخرفية
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                // شريط علوي خفيف
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 40),
                      Image.asset('assets/logo.png', height: 36),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                // أيقونة النجاح
                _buildSuccessAnimation(),
                const SizedBox(height: 40),
                // النص الرئيسي
                const Text(
                  'تم التحقق بنجاح! 🎉',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    'تم التحقق من هويتك بنجاح.\nيمكنك الآن الاستمتاع بخدمات قطرة مطر.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[500],
                      height: 1.7,
                    ),
                  ),
                ),
                const Spacer(flex: 1),
                // بطاقة المعلومات
                _buildInfoCard(context),
                const Spacer(flex: 1),
                // زر الاستمرار
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildContinueButton(context),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // دوائر متداخلة
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.success.withValues(alpha: 0.08),
          ),
        ),
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.success.withValues(alpha: 0.12),
          ),
        ),
        // الدائرة الرئيسية
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.success,
                AppTheme.success.withValues(alpha: 0.7),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.success.withValues(alpha: 0.35),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 56,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // النص
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'الحساب جاهز!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'يمكنك الآن تسجيل الدخول\nوالاستمتاع بجميع الخدمات',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppTheme.onSurfaceVariant,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // أيقونة
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/logo.png',
                width: 30,
                height: 30,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'تسجيل الدخول الآن',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
          ],
        ),
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
          Positioned(
            top: -30,
            right: -20,
            child: _buildBubble(120, const Color(0x1A1A4D8C)),
          ),
          Positioned(
            top: 80,
            right: 30,
            child: _buildBubble(50, const Color(0x151A4D8C)),
          ),
          Positioned(
            top: 60,
            left: -30,
            child: _buildBubble(80, const Color(0x101A4D8C)),
          ),
          Positioned(
            bottom: 150,
            left: -40,
            child: _buildBubble(140, const Color(0x0A1A4D8C)),
          ),
          Positioned(
            bottom: 80,
            right: -10,
            child: _buildBubble(70, const Color(0x121A4D8C)),
          ),
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
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
    );
  }
}
