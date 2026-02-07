import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/beautishop/presentation/pages/shop_detail_page.dart';
import 'package:mobile_owner/features/beautishop/presentation/pages/shop_registration_page.dart';
import 'package:mobile_owner/features/home/presentation/providers/home_provider.dart';
import 'package:mobile_owner/features/home/presentation/widgets/empty_shop_guide.dart';
import 'package:mobile_owner/features/home/presentation/widgets/shop_summary_card.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class MyShopTab extends ConsumerWidget {
  const MyShopTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeNotifierProvider);

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.pastelPink,
        onRefresh: () => ref.read(homeNotifierProvider.notifier).refresh(),
        child: _buildContent(context, ref, state),
      ),
      floatingActionButton: state.hasShops
          ? FloatingActionButton(
              onPressed: () => _navigateToRegister(context, ref),
              backgroundColor: AppColors.pastelPink,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, HomeState state) {
    switch (state.status) {
      case HomeStatus.initial:
      case HomeStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.pastelPink),
        );
      case HomeStatus.error:
        return CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: Center(
                child: Text(
                  state.errorMessage ?? '오류가 발생했습니다',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        );
      case HomeStatus.loaded:
        return _buildLoaded(context, ref, state);
    }
  }

  Widget _buildLoaded(BuildContext context, WidgetRef ref, HomeState state) {
    if (!state.hasShops) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 40),
          EmptyShopGuide(
            onRegisterTap: () => _navigateToRegister(context, ref),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: state.shops.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              '내 뷰티샵',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          );
        }
        final shop = state.shops[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ShopSummaryCard(
            shop: shop,
            onTap: () => _navigateToDetail(context, ref, shop.id),
          ),
        );
      },
    );
  }

  Future<void> _navigateToRegister(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ShopRegistrationPage()),
    );
    if (result == true) {
      ref.read(homeNotifierProvider.notifier).refresh();
    }
  }

  Future<void> _navigateToDetail(
    BuildContext context,
    WidgetRef ref,
    String shopId,
  ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ShopDetailPage(shopId: shopId)),
    );
    if (result == true) {
      ref.read(homeNotifierProvider.notifier).refresh();
    }
  }
}
