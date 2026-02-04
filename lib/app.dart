import 'package:flutter/material.dart';
import 'package:mobile_owner/config/theme.dart';
import 'package:mobile_owner/features/auth/presentation/pages/login_page.dart';
import 'package:mobile_owner/features/auth/presentation/pages/sign_up_page.dart';
import 'package:mobile_owner/features/auth/presentation/pages/splash_page.dart';
import 'package:mobile_owner/features/home/presentation/pages/home_page.dart';

class OwnerApp extends StatelessWidget {
  const OwnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '젤로마크 사장님',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppTheme.lightTheme,
      home: const SplashPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/sign-up': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
