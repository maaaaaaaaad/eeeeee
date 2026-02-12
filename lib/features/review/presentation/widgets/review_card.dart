import 'package:flutter/material.dart';
import 'package:mobile_owner/features/review/domain/entities/shop_review.dart';
import 'package:mobile_owner/features/review/presentation/widgets/rating_stars_display.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class ReviewCard extends StatelessWidget {
  final ShopReview review;
  final void Function(List<String> images, int index) onImageTap;

  const ReviewCard({
    super.key,
    required this.review,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (review.hasContent) ...[
            const SizedBox(height: 10),
            Text(
              review.content!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ],
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildImageRow(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          review.maskedAuthorName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (review.rating != null) ...[
          const SizedBox(width: 8),
          RatingStarsDisplay(rating: review.rating!),
        ],
        const Spacer(),
        Text(
          _formatDate(review.createdAt),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textHint,
          ),
        ),
        if (review.isEdited) ...[
          const SizedBox(width: 4),
          const Text(
            '(수정됨)',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textHint,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageRow() {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: review.images.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) => GestureDetector(
          key: Key('review_image_$index'),
          onTap: () => onImageTap(review.images, index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              review.images[index],
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 72,
                height: 72,
                color: AppColors.backgroundMedium,
                child: const Icon(
                  Icons.broken_image,
                  size: 24,
                  color: AppColors.textHint,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) return '방금 전';
      return '${diff.inHours}시간 전';
    }
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    if (diff.inDays < 30) return '${diff.inDays ~/ 7}주 전';
    if (diff.inDays < 365) return '${diff.inDays ~/ 30}개월 전';
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
