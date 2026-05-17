import 'package:flutter/material.dart';
import '../main.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'home_screen.dart';
import 'employee_screen.dart';
import 'admin_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar('يرجى إدخال رقم الهاتف وكلمة المرور', isError: true),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserModel? userModel = await _authService.signIn(
        _phoneController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (userModel != null) {
        if (userModel.role == UserRole.admin) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const AdminScreen()));
        } else if (userModel.role == UserRole.staff) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const EmployeeScreen()));
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar(e.toString(), isError: true),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  SnackBar _buildSnackBar(String message, {bool isError = false}) {
    return SnackBar(
      content: Text(message, textAlign: TextAlign.right),
      backgroundColor: isError ? AppTheme.error : AppTheme.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // خلفية متدرجة مع فقاعات ماء زخرفية
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // لوغو التطبيق الحقيقي
                  _buildLogo(),
                  const SizedBox(height: 40),
                  // بطاقة نموذج تسجيل الدخول
                  _buildLoginCard(),
                  const SizedBox(height: 28),
                  // زر تغيير اللغة
                  _buildLanguageToggle(),
                  const SizedBox(height: 16),
                  // رابط إنشاء حساب
                  _buildSignUpLink(),
                  const SizedBox(height: 24),
                ],
              ),
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

  Widget _buildLogo() {
    return Column(
      children: [
        // اللوغو الحقيقي
        Container(
          width: 110,
          height: 110,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.15),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Image.asset(
            'assets/logo.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'قطرة مطر',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 28,
            color: AppTheme.primary,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'للمياه الصحية',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.secondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.08),
            blurRadius: 40,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'تسجيل الدخول',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'مرحباً بك في قطرة مطر',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),

          // حقل رقم الهاتف
          _buildFieldLabel('رقم الهاتف'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildTextField(
                  _phoneController,
                  '7XXXXXXXX',
                  Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(width: 10),
              _buildCountryPicker(),
            ],
          ),
          const SizedBox(height: 20),

          // حقل كلمة المرور
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'نسيت كلمة المرور؟',
                  style: TextStyle(
                    color: AppTheme.secondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _buildFieldLabel('كلمة المرور'),
            ],
          ),
          const SizedBox(height: 8),
          _buildTextField(
            _passwordController,
            '••••••••',
            Icons.lock_outline,
            isPassword: true,
          ),
          const SizedBox(height: 28),

          // زر تسجيل الدخول
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        color: AppTheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      textAlign: TextAlign.right,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[350], fontSize: 14),
        suffixIcon: Icon(icon, color: AppTheme.primary.withValues(alpha: 0.5), size: 20),
        prefixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey[400],
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
      ),
    );
  }

  Widget _buildCountryPicker() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🇯🇴', style: TextStyle(fontSize: 18)),
          SizedBox(width: 6),
          Text(
            '+962',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
              fontSize: 13,
            ),
          ),
          Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
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
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.login_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLanguageToggle() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return TextButton.icon(
      onPressed: () {
        Locale next = isArabic ? const Locale('en', 'US') : const Locale('ar', 'SA');
        QatratMatarApp.setLocale(context, next);
      },
      icon: const Icon(Icons.language_rounded, size: 18, color: AppTheme.primary),
      label: Text(
        isArabic ? 'English' : 'العربية',
        style: const TextStyle(
          color: AppTheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignUpScreen()),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
            ),
            child: const Text(
              'سجّل الآن',
              style: TextStyle(
                color: AppTheme.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const Text(
            '  ليس لديك حساب؟',
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
