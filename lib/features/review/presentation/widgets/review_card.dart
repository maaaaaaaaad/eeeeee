import 'package:flutter/material.dart';
import 'package:mobile_owner/features/review/domain/entities/shop_review.dart';
import 'package:mobile_owner/features/review/presentation/widgets/rating_stars_display.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class ReviewCard extends StatelessWidget {
  final ShopReview review;
  final void Function(List<String> images, int index) onImageTap;
  final VoidCallback? onReplyTap;
  final VoidCallback? onReplyEdit;
  final VoidCallback? onReplyDelete;

  const ReviewCard({
    super.key,
    required this.review,
    required this.onImageTap,
    this.onReplyTap,
    this.onReplyEdit,
    this.onReplyDelete,
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
          const SizedBox(height: 10),
          if (review.hasReply)
            _buildReplySection()
          else
            _buildReplyButton(),
        ],
      ),
    );
  }

  Widget _buildReplySection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '사장님 답글',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (onReplyEdit != null)
                GestureDetector(
                  key: const Key('reply_edit_button'),
                  onTap: onReplyEdit,
                  child: const Text(
                    '수정',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              if (onReplyEdit != null && onReplyDelete != null)
                const SizedBox(width: 12),
              if (onReplyDelete != null)
                GestureDetector(
                  key: const Key('reply_delete_button'),
                  onTap: onReplyDelete,
                  child: const Text(
                    '삭제',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            review.ownerReplyContent!,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          if (review.ownerReplyCreatedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              _formatFullDate(review.ownerReplyCreatedAt!),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textHint,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReplyButton() {
    return GestureDetector(
      key: const Key('reply_button'),
      onTap: onReplyTap,
      child: const Row(
        children: [
          Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.textSecondary),
          SizedBox(width: 4),
          Text(
            '답글 달기',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
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
