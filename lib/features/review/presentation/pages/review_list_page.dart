import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/review/presentation/providers/review_list_provider.dart';
import 'package:mobile_owner/features/review/presentation/widgets/full_screen_image_viewer.dart';
import 'package:mobile_owner/features/review/presentation/widgets/reply_input_dialog.dart';
import 'package:mobile_owner/features/review/presentation/widgets/review_card.dart';
import 'package:mobile_owner/features/review/presentation/widgets/review_stats_header.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class ReviewListPage extends ConsumerStatefulWidget {
  final String shopId;
  final double averageRating;
  final int reviewCount;

  const ReviewListPage({
    super.key,
    required this.shopId,
    required this.averageRating,
    required this.reviewCount,
  });

  @override
  ConsumerState<ReviewListPage> createState() => _ReviewListPageState();
}

class _ReviewListPageState extends ConsumerState<ReviewListPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(reviewListNotifierProvider(widget.shopId).notifier)
          .loadReviews();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(reviewListNotifierProvider(widget.shopId).notifier)
          .loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewListNotifierProvider(widget.shopId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '리뷰 관리',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          ReviewStatsHeader(
            averageRating: widget.averageRating,
            reviewCount: widget.reviewCount,
            currentSort: state.sortType,
            onSortChanged: (sort) {
              ref
                  .read(reviewListNotifierProvider(widget.shopId).notifier)
                  .changeSort(sort);
            },
          ),
          const Divider(height: 1),
          Expanded(child: _buildBody(state)),
        ],
      ),
    );
  }

  Widget _buildBody(ReviewListState state) {
    switch (state.status) {
      case ReviewListStatus.initial:
      case ReviewListStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.pastelPink),
        );
      case ReviewListStatus.error:
        if (state.reviews.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.textHint),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage ?? '오류가 발생했습니다',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => ref
                      .read(
                          reviewListNotifierProvider(widget.shopId).notifier)
                      .loadReviews(),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          );
        }
        return _buildList(state);
      case ReviewListStatus.loaded:
      case ReviewListStatus.loadingMore:
        if (state.reviews.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rate_review_outlined,
                    size: 48, color: AppColors.textHint),
                SizedBox(height: 16),
                Text(
                  '아직 리뷰가 없습니다',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }
        return _buildList(state);
    }
  }

  Widget _buildList(ReviewListState state) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount:
          state.reviews.length + (state.status == ReviewListStatus.loadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == state.reviews.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: AppColors.pastelPink),
            ),
          );
        }
        final review = state.reviews[index];
        return ReviewCard(
          review: review,
          onImageTap: _openImageViewer,
          onReplyTap: () => _showReplyDialog(review.id),
          onReplyEdit: review.hasReply
              ? () => _showReplyDialog(review.id, review.ownerReplyContent)
              : null,
          onReplyDelete: review.hasReply
              ? () => _confirmDeleteReply(review.id)
              : null,
        );
      },
    );
  }

  void _openImageViewer(List<String> images, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImageViewer(
          images: images,
          initialIndex: index,
        ),
      ),
    );
  }

  Future<void> _showReplyDialog(String reviewId, [String? initialContent]) async {
    final content = await showDialog<String>(
      context: context,
      builder: (_) => ReplyInputDialog(initialContent: initialContent),
    );

    if (content == null || !mounted) return;

    final success = await ref
        .read(reviewListNotifierProvider(widget.shopId).notifier)
        .replyToReview(reviewId, content);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('답글 등록에 실패했습니다')),
      );
    }
  }

  Future<void> _confirmDeleteReply(String reviewId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('답글 삭제'),
        content: const Text('답글을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '삭제',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await ref
        .read(reviewListNotifierProvider(widget.shopId).notifier)
        .deleteReviewReply(reviewId);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('답글 삭제에 실패했습니다')),
      );
    }
  }
}
