import 'package:flutter/material.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class ShopSummaryCard extends StatelessWidget {
  final BeautyShop shop;
  final VoidCallback? onTap;

  const ShopSummaryCard({super.key, required this.shop, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.store, color: AppColors.pastelPink, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    shop.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textHint,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on_outlined, shop.address),
            const SizedBox(height: 6),
            _buildInfoRow(Icons.phone_outlined, shop.phoneNumber),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatChip(
                  Icons.star,
                  shop.averageRating.toStringAsFixed(1),
                  Colors.amber,
                ),
                const SizedBox(width: 12),
                _buildStatChip(
                  Icons.rate_review_outlined,
                  '${shop.reviewCount}',
                  AppColors.pastelPink,
                ),
                if (shop.categories.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  _buildStatChip(
                    Icons.category_outlined,
                    shop.categories.length.toString(),
                    AppColors.lavenderDark,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
