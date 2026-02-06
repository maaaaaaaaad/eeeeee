import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/home/presentation/providers/home_provider.dart';
import 'package:mobile_owner/features/home/presentation/widgets/empty_shop_guide.dart';
import 'package:mobile_owner/features/home/presentation/widgets/owner_profile_card.dart';
import 'package:mobile_owner/features/home/presentation/widgets/shop_summary_card.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeNotifierProvider);

    return RefreshIndicator(
      color: AppColors.pastelPink,
      onRefresh: () => ref.read(homeNotifierProvider.notifier).refresh(),
      child: _buildContent(state),
    );
  }

  Widget _buildContent(HomeState state) {
    switch (state.status) {
      case HomeStatus.initial:
      case HomeStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.pastelPink),
        );
      case HomeStatus.error:
        return _buildError(state.errorMessage ?? '오류가 발생했습니다');
      case HomeStatus.loaded:
        return _buildLoaded(state);
    }
  }

  Widget _buildError(String message) {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.textHint,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  '아래로 당겨서 다시 시도해 주세요',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoaded(HomeState state) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (state.owner != null) ...[
          OwnerProfileCard(owner: state.owner!),
          const SizedBox(height: 24),
        ],
        const Text(
          '내 뷰티샵',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (state.hasShops)
          ...state.shops.map(
            (shop) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ShopSummaryCard(shop: shop),
            ),
          )
        else
          const EmptyShopGuide(),
      ],
    );
  }
}
