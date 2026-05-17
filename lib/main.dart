import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/complete_profile_screen.dart';
import 'screens/verification_success_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const QatratMatarApp());
}

class QatratMatarApp extends StatefulWidget {
  const QatratMatarApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _QatratMatarAppState? state = context.findAncestorStateOfType<_QatratMatarAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<QatratMatarApp> createState() => _QatratMatarAppState();
}

class _QatratMatarAppState extends State<QatratMatarApp> {
  Locale _locale = const Locale('ar', 'SA');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'قطرة مطر',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: _locale,
      supportedLocales: const [
        Locale('ar', 'SA'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/complete-profile': (context) => const CompleteProfileScreen(),
        '/verification-success': (context) => const VerificationSuccessScreen(),
      },
      initialRoute: '/',
    );
  }
}
