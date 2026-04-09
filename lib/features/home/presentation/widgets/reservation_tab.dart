import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation.dart';
import 'package:mobile_owner/features/reservation/presentation/pages/reservation_detail_page.dart';
import 'package:mobile_owner/features/reservation/presentation/providers/owner_reservation_list_provider.dart';
import 'package:mobile_owner/features/reservation/presentation/widgets/reservation_card.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class ReservationTab extends ConsumerStatefulWidget {
  const ReservationTab({super.key});

  @override
  ConsumerState<ReservationTab> createState() => _ReservationTabState();
}

class _ReservationTabState extends ConsumerState<ReservationTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ownerReservationListNotifierProvider.notifier).loadReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ownerReservationListNotifierProvider);

    if (state.isLoading && state.reservations.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.pastelPink),
      );
    }

    if (state.error != null && state.reservations.isEmpty) {
      return _buildErrorState(state.error!);
    }

    if (state.pendingReservations.isEmpty && state.confirmedReservations.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppColors.pastelPink,
      onRefresh: () =>
          ref.read(ownerReservationListNotifierProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (state.pendingReservations.isNotEmpty) ...[
            _buildSectionHeader(
              '확정 대기 (${state.pendingReservations.length}건)',
            ),
            const SizedBox(height: 8),
            ...state.pendingReservations.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ReservationCard(
                  reservation: r,
                  onTap: () => _navigateToDetail(r),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (state.confirmedReservations.isNotEmpty) ...[
            _buildSectionHeader(
              '확정 (${state.confirmedReservations.length}건)',
            ),
            const SizedBox(height: 8),
            ...state.confirmedReservations.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ReservationCard(
                  reservation: r,
                  onTap: () => _navigateToDetail(r),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 48,
            color: AppColors.textHint,
          ),
          SizedBox(height: 16),
          Text(
            '현재 예약이 없습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '새로운 예약이 들어오면 여기에 표시됩니다',
            style: TextStyle(fontSize: 13, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref
                .read(ownerReservationListNotifierProvider.notifier)
                .loadReservations(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pastelPink,
              foregroundColor: Colors.white,
            ),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToDetail(Reservation reservation) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ReservationDetailPage(reservation: reservation),
      ),
    );
    if (result == true) {
      ref.read(ownerReservationListNotifierProvider.notifier).refresh();
    }
  }
}
