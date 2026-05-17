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

  void _handleLogin() async {
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال رقم الهاتف وكلمة المرور')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // [FIX BUG-08] signIn ترمي استثناءً برسالة واضحة عند أي خطأ
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
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red[700],
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // App Logo and Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.water_drop, color: AppTheme.primary, size: 30),
                    const SizedBox(width: 8),
                    const Text(
                      'قطرة مطر',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                
                // Form Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildInputLabel('رقم الهاتف'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildTextField(_phoneController, '7XXXXXXXX', Icons.phone_outlined, keyboardType: TextInputType.phone),
                          ),
                          const SizedBox(width: 10),
                          _buildCountryPicker(),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                            },
                            child: const Text(
                              'نسيت كلمة المرور؟',
                              style: TextStyle(color: Color(0xFF4A90E2), fontSize: 13),
                            ),
                          ),
                          _buildInputLabel('كلمة المرور'),
                        ],
                      ),
                      _buildTextField(_passwordController, '........', Icons.lock_outline, isPassword: true),
                      
                      const SizedBox(height: 30),
                      // Login Button
                      Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1A4D8C), Color(0xFF2E5E9E)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1A4D8C).withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'تسجيل الدخول برقم الهاتف',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                // زر تغيير اللغة
                TextButton.icon(
                  onPressed: () {
                    Locale current = Localizations.localeOf(context);
                    Locale next = current.languageCode == 'ar' ? const Locale('en', 'US') : const Locale('ar', 'SA');
                    QatratMatarApp.setLocale(context, next);
                  },
                  icon: const Icon(Icons.language, size: 20, color: AppTheme.primary),
                  label: Text(
                    Localizations.localeOf(context).languageCode == 'ar' ? 'English' : 'العربية',
                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
                      },
                      child: const Text(
                        'سجل الآن',
                        style: TextStyle(color: Color(0xFF4A90E2), fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Text(
                      'ليس لديك حساب؟',
                      style: TextStyle(color: Color(0xFF1A4D8C)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        color: AppTheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      textAlign: TextAlign.right,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[300], fontSize: 14),
        suffixIcon: Icon(icon, color: Colors.grey[400]),
        prefixIcon: isPassword 
          ? IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey[400], size: 20),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ) 
          : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppTheme.primary),
        ),
      ),
    );
  }

  Widget _buildCountryPicker() {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: const [
          Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
          SizedBox(width: 4),
          Text('962+', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          SizedBox(width: 8),
          // Using a placeholder for flag, can use Emoji or Image.asset
          Text('🇯🇴', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
