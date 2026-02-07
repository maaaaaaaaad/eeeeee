import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reject_reservation_params.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation_status.dart';
import 'package:mobile_owner/features/reservation/presentation/providers/reservation_action_provider.dart';
import 'package:mobile_owner/features/reservation/presentation/widgets/reject_reservation_dialog.dart';
import 'package:mobile_owner/features/reservation/presentation/widgets/reservation_status_badge.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class ReservationDetailPage extends ConsumerWidget {
  final Reservation reservation;

  const ReservationDetailPage({super.key, required this.reservation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(reservationActionNotifierProvider, (prev, next) {
      if (next.status == ReservationActionStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('처리되었습니다')),
        );
        Navigator.pop(context, true);
      }
      if (next.status == ReservationActionStatus.error &&
          next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    final actionState = ref.watch(reservationActionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '예약 상세',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildStatusSection(),
          const SizedBox(height: 20),
          _buildInfoSection(),
          const SizedBox(height: 20),
          _buildTimeSection(),
          if (reservation.memo != null && reservation.memo!.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildMemoSection(),
          ],
          if (reservation.rejectionReason != null &&
              reservation.rejectionReason!.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildRejectionReasonSection(),
          ],
          const SizedBox(height: 32),
          _buildActionButtons(context, ref, actionState),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '예약 상태',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        ReservationStatusBadge(status: reservation.status),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '예약 정보',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow(Icons.person_outline, reservation.memberNickname ?? '-'),
        _buildInfoRow(
            Icons.content_cut, reservation.treatmentName ?? '-'),
        if (reservation.treatmentPrice != null)
          _buildInfoRow(Icons.payments_outlined,
              '${_formatPrice(reservation.treatmentPrice!)}원'),
        if (reservation.treatmentDuration != null)
          _buildInfoRow(
              Icons.timer_outlined, '${reservation.treatmentDuration}분'),
      ],
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '예약 일시',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow(Icons.calendar_today, reservation.reservationDate),
        _buildInfoRow(Icons.access_time,
            '${reservation.startTime} - ${reservation.endTime}'),
      ],
    );
  }

  Widget _buildMemoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '메모',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          reservation.memo!,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildRejectionReasonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '거절 사유',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          reservation.rejectionReason!,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    ReservationActionState actionState,
  ) {
    final isLoading = actionState.status == ReservationActionStatus.loading;

    if (reservation.status == ReservationStatus.pending) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () => ref
                      .read(reservationActionNotifierProvider.notifier)
                      .confirm(reservation.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pastelPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('확정'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading
                  ? null
                  : () => _onReject(context, ref),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('거절'),
            ),
          ),
        ],
      );
    }

    if (reservation.status == ReservationStatus.confirmed) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () => ref
                      .read(reservationActionNotifierProvider.notifier)
                      .complete(reservation.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pastelPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('시술 완료'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading
                  ? null
                  : () => ref
                      .read(reservationActionNotifierProvider.notifier)
                      .noShow(reservation.id),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('노쇼'),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _onReject(BuildContext context, WidgetRef ref) async {
    final reason = await RejectReservationDialog.show(context);
    if (reason != null && context.mounted) {
      ref.read(reservationActionNotifierProvider.notifier).reject(
            RejectReservationParams(
              reservationId: reservation.id,
              rejectionReason: reason,
            ),
          );
    }
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

  String _formatPrice(int price) {
    final text = price.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(text[i]);
    }
    return buffer.toString();
  }
}
