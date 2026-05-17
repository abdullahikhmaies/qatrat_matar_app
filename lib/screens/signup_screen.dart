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
  // [FIX L-01] تغيير من final إلى متغير ليسمح بتبديل إظهار/إخفاء كلمة المرور
  bool _obscurePassword = true;

  void _handleSendOTP() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال الاسم ورقم الهاتف')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool exists = await _authService.isPhoneRegistered(_phoneController.text.trim());
      if (exists) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('رقم الهاتف مسجل بالفعل')),
        );
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل إرسال الرمز: ${e.message}')),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    }
  }

  void _handleVerifyOTP() async {
    if (_otpController.text.length < 6) return;

    setState(() => _isLoading = true);
    bool success = await _authService.verifyOTP(
      verificationId: _verificationId,
      smsCode: _otpController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) setState(() => _currentStep = 2);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('رمز التحقق غير صحيح')),
        );
      }
    }
  }

  void _handleFinalSignUp() async {
    if (_passwordController.text.length < 6) return;

    setState(() => _isLoading = true);
    
    try {
      UserModel? userModel = await _authService.signUpCustomer(
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      
      if (userModel != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CompleteProfileScreen()),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('إنشاء حساب', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F1FF), Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_currentStep == 0) ...[
                      _buildLabel('الاسم الكامل'),
                      _buildTextField(_nameController, 'أدخل اسمك بالكامل', Icons.person_outline),
                      const SizedBox(height: 20),
                      _buildLabel('رقم الهاتف'),
                      _buildTextField(_phoneController, '07XXXXXXXX', Icons.phone_outlined, keyboardType: TextInputType.phone),
                    ] else if (_currentStep == 1) ...[
                      const Center(child: Text('تم إرسال رمز التحقق إلى رقمك', style: TextStyle(color: Colors.grey))),
                      const SizedBox(height: 20),
                      _buildLabel('رمز التحقق'),
                      _buildTextField(_otpController, 'أدخل الرمز (6 أرقام)', Icons.lock_clock_outlined, keyboardType: TextInputType.number),
                    ] else ...[
                      _buildLabel('كلمة المرور'),
                      _buildTextField(_passwordController, '........', Icons.lock_outline, isPassword: true),
                    ],
                    const SizedBox(height: 32),
                    _buildActionButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
  );

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      textAlign: TextAlign.right,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: Icon(icon, color: Colors.grey[400]),
        prefixIcon: isPassword 
          ? IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey[400], size: 20),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ) 
          : null,
        filled: true, fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppTheme.primary)),
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      width: double.infinity, height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(colors: [Color(0xFF1A4D8C), Color(0xFF2E5E9E)]),
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : () {
          if (_currentStep == 0) {
            _handleSendOTP();
          } else if (_currentStep == 1) {
            _handleVerifyOTP();
          } else {
            _handleFinalSignUp();
          }
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(_currentStep == 0 ? 'إرسال رمز التحقق' : (_currentStep == 1 ? 'تحقق' : 'إنشاء الحساب'),
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
