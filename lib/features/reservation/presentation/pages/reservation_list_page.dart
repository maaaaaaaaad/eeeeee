import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation_status.dart';
import 'package:mobile_owner/features/reservation/presentation/pages/reservation_detail_page.dart';
import 'package:mobile_owner/features/reservation/presentation/providers/reservation_list_provider.dart';
import 'package:mobile_owner/features/reservation/presentation/widgets/reservation_card.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class ReservationListPage extends ConsumerStatefulWidget {
  final String shopId;

  const ReservationListPage({super.key, required this.shopId});

  @override
  ConsumerState<ReservationListPage> createState() =>
      _ReservationListPageState();
}

class _ReservationListPageState extends ConsumerState<ReservationListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(reservationListNotifierProvider(widget.shopId).notifier)
          .loadReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reservationListNotifierProvider(widget.shopId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '예약 관리',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildFilterTabs(state),
          Expanded(child: _buildBody(state)),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(ReservationListState state) {
    final filters = <(String, ReservationStatus?)>[
      ('전체', null),
      ('대기중', ReservationStatus.pending),
      ('확정', ReservationStatus.confirmed),
      ('완료', ReservationStatus.completed),
      ('거절/취소', ReservationStatus.rejected),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filters.map((filter) {
          final isSelected = state.filterStatus == filter.$2;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter.$1),
              selected: isSelected,
              onSelected: (_) {
                ref
                    .read(reservationListNotifierProvider(widget.shopId).notifier)
                    .filterByStatus(isSelected ? null : filter.$2);
              },
              selectedColor: AppColors.lightPink,
              checkmarkColor: AppColors.accentPink,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody(ReservationListState state) {
    switch (state.status) {
      case ReservationListStatus.initial:
      case ReservationListStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.pastelPink),
        );
      case ReservationListStatus.error:
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
            ],
          ),
        );
      case ReservationListStatus.loaded:
        final filtered = state.filteredReservations;
        if (filtered.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 48, color: AppColors.textHint),
                SizedBox(height: 16),
                Text(
                  '예약이 없습니다',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, index) {
            final reservation = filtered[index];
            return ReservationCard(
              reservation: reservation,
              onTap: () => _navigateToDetail(reservation),
            );
          },
        );
    }
  }

  Future<void> _navigateToDetail(Reservation reservation) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ReservationDetailPage(reservation: reservation),
      ),
    );
    if (result == true) {
      ref
          .read(reservationListNotifierProvider(widget.shopId).notifier)
          .refresh();
    }
  }
}
