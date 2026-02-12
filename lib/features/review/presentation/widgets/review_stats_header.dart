import 'package:flutter/material.dart';
import 'package:mobile_owner/features/review/presentation/providers/review_list_provider.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class ReviewStatsHeader extends StatelessWidget {
  final double averageRating;
  final int reviewCount;
  final ReviewSortType currentSort;
  final ValueChanged<ReviewSortType> onSortChanged;

  const ReviewStatsHeader({
    super.key,
    required this.averageRating,
    required this.reviewCount,
    required this.currentSort,
    required this.onSortChanged,
  });

  static const _sortLabels = {
    ReviewSortType.latestFirst: '최신순',
    ReviewSortType.oldestFirst: '오래된순',
    ReviewSortType.highestRating: '높은 평점순',
    ReviewSortType.lowestRating: '낮은 평점순',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 22),
          const SizedBox(width: 4),
          Text(
            averageRating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '·',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '리뷰 $reviewCount건',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          PopupMenuButton<ReviewSortType>(
            onSelected: onSortChanged,
            initialValue: currentSort,
            itemBuilder: (context) => ReviewSortType.values
                .map((sort) => PopupMenuItem(
                      value: sort,
                      child: Text(_sortLabels[sort]!),
                    ))
                .toList(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _sortLabels[currentSort]!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
