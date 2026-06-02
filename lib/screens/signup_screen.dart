import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'complete_profile_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  int _currentStep = 0; // 0: Info, 1: OTP, 2: Password
  bool _isLoading = false;
  String _verificationId = "";
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSendOTP() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      _showSnackBar('يرجى إدخال الاسم ورقم الهاتف', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool exists = await _authService.isPhoneRegistered(_phoneController.text.trim());
      if (exists) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showSnackBar('رقم الهاتف مسجل بالفعل', isError: true);
        return;
      }

      await _authService.sendOTP(
        phone: _phoneController.text.trim(),
        onCodeSent: (id) {
          if (!mounted) return;
          setState(() {
            _verificationId = id;
            _currentStep = 1;
            _isLoading = false;
          });
        },
        onFailed: (e) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          _showSnackBar('فشل إرسال الرمز: ${e.message ?? 'خطأ غير معروف'}', isError: true);
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('خطأ: $e', isError: true);
    }
  }

  void _handleVerifyOTP() async {
    if (_otpController.text.length < 6) {
      _showSnackBar('يرجى إدخال رمز مكون من 6 أرقام', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    bool success = await _authService.verifyOTP(
      verificationId: _verificationId,
      smsCode: _otpController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      if (mounted) setState(() => _currentStep = 2);
    } else {
      if (mounted) _showSnackBar('رمز التحقق غير صحيح', isError: true);
    }
  }

  void _handleFinalSignUp() async {
    if (_passwordController.text.length < 6) {
      _showSnackBar('كلمة المرور يجب أن تكون 6 أحرف على الأقل', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserModel? userModel = await _authService.signUpCustomer(
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (userModel != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CompleteProfileScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('خطأ: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.right),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
            child: Column(
              children: [
                // شريط العنوان المخصص
                _buildCustomAppBar(),
                // مؤشر الخطوات
                _buildStepIndicator(),
                // المحتوى
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // أيقونة الخطوة
                        _buildStepIcon(),
                        const SizedBox(height: 24),
                        // بطاقة النموذج
                        _buildFormCard(),
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

  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: Stack(
        children: [
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

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // اللوغو
          Image.asset('assets/logo.png', height: 36),
          // عنوان وزر رجوع
          Row(
            children: [
              Text(
                'إنشاء حساب',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  if (_currentStep > 0) {
                    setState(() => _currentStep--);
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: isCurrent ? 6 : 4,
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.primary : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                if (index < 2) const SizedBox(width: 6),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepIcon() {
    final List<IconData> icons = [
      Icons.person_outline_rounded,
      Icons.sms_outlined,
      Icons.lock_outline_rounded,
    ];
    final List<String> titles = [
      'معلوماتك الشخصية',
      'التحقق من الهاتف',
      'كلمة المرور',
    ];
    final List<String> subtitles = [
      'أدخل اسمك ورقم هاتفك',
      'تم إرسال رمز التحقق إلى رقمك',
      'اختر كلمة مرور قوية',
    ];

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icons[_currentStep], color: Colors.white, size: 36),
        ),
        const SizedBox(height: 16),
        Text(
          titles[_currentStep],
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitles[_currentStep],
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.07),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_currentStep == 0) ...[
            _buildLabel('الاسم الكامل'),
            _buildTextField(_nameController, 'أدخل اسمك بالكامل', Icons.person_outline),
            const SizedBox(height: 20),
            _buildLabel('رقم الهاتف'),
            _buildTextField(
              _phoneController,
              '07XXXXXXXX',
              Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
          ] else if (_currentStep == 1) ...[
            _buildLabel('رمز التحقق'),
            // حقل OTP مميز
            _buildOTPField(),
          ] else ...[
            _buildLabel('كلمة المرور'),
            _buildTextField(
              _passwordController,
              '••••••••',
              Icons.lock_outline,
              isPassword: true,
            ),
          ],
          const SizedBox(height: 32),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: AppTheme.primary,
        fontSize: 14,
      ),
    ),
  );

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
      style: const TextStyle(fontSize: 15),
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

  Widget _buildOTPField() {
    return TextField(
      controller: _otpController,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      maxLength: 6,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: 8,
        color: AppTheme.primary,
      ),
      decoration: InputDecoration(
        counterText: '',
        hintText: '------',
        hintStyle: TextStyle(
          color: Colors.grey[300],
          fontSize: 22,
          letterSpacing: 8,
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    final List<String> labels = [
      'إرسال رمز التحقق',
      'تحقق من الرمز',
      'إنشاء الحساب',
    ];

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
        onPressed: _isLoading
            ? null
            : () {
                if (_currentStep == 0) {
                  _handleSendOTP();
                } else if (_currentStep == 1) {
                  _handleVerifyOTP();
                } else {
                  _handleFinalSignUp();
                }
              },
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
                children: [
                  Text(
                    labels[_currentStep],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                ],
              ),
      ),
    );
  }
}
