import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reject_reservation_params.dart';
import 'package:mobile_owner/features/reservation/presentation/providers/reservation_provider.dart';

final reservationActionNotifierProvider = AutoDisposeNotifierProvider<
    ReservationActionNotifier, ReservationActionState>(
  () => ReservationActionNotifier(),
);

class ReservationActionNotifier
    extends AutoDisposeNotifier<ReservationActionState> {
  @override
  ReservationActionState build() {
    return const ReservationActionState();
  }

  Future<void> confirm(String reservationId) async {
    state = state.copyWith(status: ReservationActionStatus.loading);

    final useCase = ref.read(confirmReservationUseCaseProvider);
    final result = await useCase(reservationId);

    result.fold(
      (failure) => state = state.copyWith(
        status: ReservationActionStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(status: ReservationActionStatus.success),
    );
  }

  Future<void> reject(RejectReservationParams params) async {
    state = state.copyWith(status: ReservationActionStatus.loading);

    final useCase = ref.read(rejectReservationUseCaseProvider);
    final result = await useCase(params);

    result.fold(
      (failure) => state = state.copyWith(
        status: ReservationActionStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(status: ReservationActionStatus.success),
    );
  }

  Future<void> complete(String reservationId) async {
    state = state.copyWith(status: ReservationActionStatus.loading);

    final useCase = ref.read(completeReservationUseCaseProvider);
    final result = await useCase(reservationId);

    result.fold(
      (failure) => state = state.copyWith(
        status: ReservationActionStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(status: ReservationActionStatus.success),
    );
  }

  Future<void> noShow(String reservationId) async {
    state = state.copyWith(status: ReservationActionStatus.loading);

    final useCase = ref.read(noShowReservationUseCaseProvider);
    final result = await useCase(reservationId);

    result.fold(
      (failure) => state = state.copyWith(
        status: ReservationActionStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(status: ReservationActionStatus.success),
    );
  }
}

enum ReservationActionStatus { initial, loading, success, error }

class ReservationActionState extends Equatable {
  final ReservationActionStatus status;
  final String? errorMessage;

  const ReservationActionState({
    this.status = ReservationActionStatus.initial,
    this.errorMessage,
  });

  ReservationActionState copyWith({
    ReservationActionStatus? status,
    String? errorMessage,
  }) {
    return ReservationActionState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
