import 'package:flutter/material.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class LegalTextPage extends StatelessWidget {
  final String title;
  final String body;

  const LegalTextPage({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SelectionArea(
            child: Text(
              body,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
