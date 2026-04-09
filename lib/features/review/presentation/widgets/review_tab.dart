import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/home/presentation/providers/home_provider.dart';
import 'package:mobile_owner/features/review/presentation/pages/review_list_page.dart';
import 'package:mobile_owner/features/review/presentation/providers/review_tab_provider.dart';
import 'package:mobile_owner/features/review/presentation/widgets/review_room_card.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class ReviewTab extends ConsumerWidget {
  const ReviewTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeNotifierProvider);
    final reviewTabState = ref.watch(reviewTabNotifierProvider);
    final shops = homeState.shops;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '리뷰',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: shops.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rate_review_outlined, size: 48, color: AppColors.textHint),
                  SizedBox(height: 16),
                  Text(
                    '등록된 샵이 없습니다',
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '샵을 등록하면 리뷰를 관리할 수 있습니다',
                    style: TextStyle(fontSize: 13, color: AppColors.textHint),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                await ref.read(homeNotifierProvider.notifier).refresh();
                await ref.read(reviewTabNotifierProvider.notifier).refresh();
              },
              child: ListView.separated(
                itemCount: shops.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final shop = shops[index];
                  final unread = reviewTabState.unreadCountFor(shop.id);

                  return ReviewRoomCard(
                    shopName: shop.name,
                    averageRating: shop.averageRating,
                    reviewCount: shop.reviewCount,
                    lastReviewContent: shop.reviewCount > 0
                        ? '리뷰 ${shop.reviewCount}개'
                        : null,
                    lastReviewDate: null,
                    unreadCount: unread,
                    onTap: () {
                      ref.read(reviewTabNotifierProvider.notifier)
                          .markShopAsRead(shop.id, shop.reviewCount);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReviewListPage(
                            shopId: shop.id,
                            averageRating: shop.averageRating,
                            reviewCount: shop.reviewCount,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
