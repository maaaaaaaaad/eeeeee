import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/beautishop/presentation/pages/category_selection_page.dart';
import 'package:mobile_owner/features/beautishop/presentation/pages/schedule_management_page.dart';
import 'package:mobile_owner/features/beautishop/presentation/pages/shop_edit_page.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/shop_detail_provider.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/category_chip_list.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/operating_hours_display.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';
import 'package:mobile_owner/features/reservation/presentation/pages/reservation_list_page.dart';
import 'package:mobile_owner/features/review/presentation/pages/review_list_page.dart';
import 'package:mobile_owner/features/treatment/presentation/pages/treatment_list_page.dart';
import 'package:mobile_owner/features/treatment/presentation/providers/treatment_list_provider.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class ShopDetailPage extends ConsumerStatefulWidget {
  final String shopId;

  const ShopDetailPage({super.key, required this.shopId});

  @override
  ConsumerState<ShopDetailPage> createState() => _ShopDetailPageState();
}

class _ShopDetailPageState extends ConsumerState<ShopDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(shopDetailNotifierProvider(widget.shopId).notifier).loadShop();
      ref
          .read(treatmentListNotifierProvider(widget.shopId).notifier)
          .loadTreatments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopDetailNotifierProvider(widget.shopId));

    ref.listen(shopDetailNotifierProvider(widget.shopId), (prev, next) {
      if (next.status == ShopDetailStatus.deleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('샵이 삭제되었습니다')),
        );
        Navigator.pop(context, true);
      }
      if (next.errorMessage != null &&
          prev?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          state.shop?.name ?? '샵 상세',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(ShopDetailState state) {
    switch (state.status) {
      case ShopDetailStatus.initial:
      case ShopDetailStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.pastelPink),
        );
      case ShopDetailStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.textHint),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? '오류가 발생했습니다',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      case ShopDetailStatus.deleting:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.pastelPink),
              SizedBox(height: 16),
              Text('삭제 중...', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        );
      case ShopDetailStatus.loaded:
      case ShopDetailStatus.deleted:
        if (state.shop == null) {
          return const Center(child: Text('샵 정보를 찾을 수 없습니다'));
        }
        return _buildDetail(state.shop!);
    }
  }

  Widget _buildDetail(BeautyShop shop) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (shop.images.isNotEmpty) ...[
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: shop.images.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, index) => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  shop.images[index],
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 200,
                    height: 200,
                    color: AppColors.backgroundMedium,
                    child: const Icon(
                      Icons.broken_image,
                      size: 40,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        _buildInfoSection('기본 정보', [
          _buildInfoRow(Icons.store, shop.name),
          _buildInfoRow(Icons.badge_outlined, shop.regNum),
          _buildInfoRow(Icons.phone_outlined, shop.phoneNumber),
          _buildInfoRow(Icons.location_on_outlined, shop.address),
        ]),
        const SizedBox(height: 20),
        _buildReviewSection(shop),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('영업 시간'),
            TextButton(
              onPressed: () => _navigateToScheduleManagement(shop),
              child: const Text('관리하기'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        OperatingHoursDisplay(operatingTime: shop.operatingTime),
        const SizedBox(height: 20),
        if (shop.description != null && shop.description!.isNotEmpty) ...[
          _buildSectionTitle('설명'),
          const SizedBox(height: 8),
          Text(
            shop.description!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
        ],
        _buildSectionTitle('카테고리'),
        const SizedBox(height: 8),
        CategoryChipList(categories: shop.categories),
        const SizedBox(height: 20),
        _buildTreatmentSection(shop),
        const SizedBox(height: 20),
        _buildReservationSection(shop),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _navigateToEdit(shop),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('수정하기'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _navigateToCategorySelection(shop),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('카테고리 설정'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _onDelete(shop),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('삭제'),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTreatmentSection(BeautyShop shop) {
    final treatmentState =
        ref.watch(treatmentListNotifierProvider(widget.shopId));
    final count = treatmentState.treatments.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('시술 관리'),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '등록된 시술 $count개',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            TextButton(
              onPressed: () => _navigateToTreatmentList(shop),
              child: const Text('관리하기'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReservationSection(BeautyShop shop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('예약 관리'),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '예약 현황 보기',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            TextButton(
              onPressed: () => _navigateToReservationList(shop),
              child: const Text('관리하기'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _navigateToReservationList(BeautyShop shop) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ReservationListPage(shopId: shop.id),
      ),
    );
  }

  Future<void> _navigateToTreatmentList(BeautyShop shop) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TreatmentListPage(shopId: shop.id),
      ),
    );
    if (result == true) {
      ref
          .read(treatmentListNotifierProvider(widget.shopId).notifier)
          .refresh();
    }
  }

  Future<void> _navigateToScheduleManagement(BeautyShop shop) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ScheduleManagementPage(shop: shop),
      ),
    );
    if (result == true) {
      ref.read(shopDetailNotifierProvider(widget.shopId).notifier).refresh();
    }
  }

  Future<void> _navigateToEdit(BeautyShop shop) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ShopEditPage(shop: shop)),
    );
    if (result == true) {
      ref.read(shopDetailNotifierProvider(widget.shopId).notifier).refresh();
    }
  }

  Future<void> _navigateToCategorySelection(BeautyShop shop) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CategorySelectionPage(
          shopId: shop.id,
          currentCategoryIds: shop.categories.map((c) => c.id).toList(),
        ),
      ),
    );
    if (result == true) {
      ref.read(shopDetailNotifierProvider(widget.shopId).notifier).refresh();
    }
  }

  Future<void> _onDelete(BeautyShop shop) async {
    final confirmed = await DeleteConfirmationDialog.show(
      context,
      shopName: shop.name,
    );
    if (confirmed == true) {
      ref.read(shopDetailNotifierProvider(widget.shopId).notifier).deleteShop();
    }
  }

  Widget _buildReviewSection(BeautyShop shop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('평점 / 리뷰'),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  shop.averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.rate_review_outlined,
                    color: AppColors.pastelPink, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${shop.reviewCount}건',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            TextButton(
              onPressed: () => _navigateToReviewList(shop),
              child: const Text('관리하기'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _navigateToReviewList(BeautyShop shop) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewListPage(
          shopId: shop.id,
          averageRating: shop.averageRating,
          reviewCount: shop.reviewCount,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
