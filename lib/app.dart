import 'package:flutter/material.dart';
import 'package:mobile_owner/config/theme.dart';

class OwnerApp extends StatelessWidget {
  const OwnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '젤로마크 사장님',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppTheme.lightTheme,
      home: const Scaffold(
        body: Center(
          child: Text('젤로마크 사장님 앱'),
        ),
      ),
    );
  }
}
