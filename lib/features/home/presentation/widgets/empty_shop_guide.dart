import 'package:flutter/material.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class EmptyShopGuide extends StatelessWidget {
  final VoidCallback? onRegisterTap;

  const EmptyShopGuide({super.key, this.onRegisterTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.lightPink.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.pastelPink.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.storefront_outlined,
            size: 64,
            color: AppColors.pastelPink,
          ),
          const SizedBox(height: 16),
          const Text(
            '아직 등록된 샵이 없어요',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '내 뷰티샵을 등록하고\n고객들에게 소개해 보세요!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onRegisterTap,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              '샵 등록하기',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.pastelPink,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
