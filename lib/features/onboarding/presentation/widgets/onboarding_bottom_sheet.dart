import 'package:flutter/material.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class OnboardingBottomSheet extends StatelessWidget {
  final VoidCallback onRegisterTap;
  final VoidCallback onDismiss;

  const OnboardingBottomSheet({
    super.key,
    required this.onRegisterTap,
    required this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onRegisterTap,
    required VoidCallback onDismiss,
  }) {
    return showModalBottomSheet(
      context: context,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => OnboardingBottomSheet(
        onRegisterTap: onRegisterTap,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.lightPink,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.storefront,
                size: 40,
                color: AppColors.accentPink,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '뷰티샵을 등록해 보세요!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '내 뷰티샵을 등록하고\n고객들에게 소개해 보세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onRegisterTap,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.pastelPink,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  '샵 등록하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onDismiss,
                child: const Text(
                  '나중에 하기',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
