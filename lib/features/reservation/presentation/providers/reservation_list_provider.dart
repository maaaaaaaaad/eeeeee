import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation_status.dart';
import 'package:mobile_owner/features/reservation/presentation/providers/reservation_provider.dart';

final reservationListNotifierProvider = AutoDisposeNotifierProviderFamily<
    ReservationListNotifier, ReservationListState, String>(
  () => ReservationListNotifier(),
);

class ReservationListNotifier
    extends AutoDisposeFamilyNotifier<ReservationListState, String> {
  @override
  ReservationListState build(String shopId) {
    return const ReservationListState();
  }

  Future<void> loadReservations() async {
    state = state.copyWith(status: ReservationListStatus.loading);

    final useCase = ref.read(getShopReservationsUseCaseProvider);
    final result = await useCase(arg);

    result.fold(
      (failure) => state = state.copyWith(
        status: ReservationListStatus.error,
        errorMessage: failure.message,
      ),
      (reservations) => state = state.copyWith(
        status: ReservationListStatus.loaded,
        reservations: reservations,
      ),
    );
  }

  void filterByStatus(ReservationStatus? status) {
    state = state.copyWith(
      filterStatus: status,
      clearFilter: status == null,
    );
  }

  Future<void> refresh() async {
    await loadReservations();
  }
}

enum ReservationListStatus { initial, loading, loaded, error }

class ReservationListState extends Equatable {
  final ReservationListStatus status;
  final List<Reservation> reservations;
  final ReservationStatus? filterStatus;
  final String? errorMessage;

  const ReservationListState({
    this.status = ReservationListStatus.initial,
    this.reservations = const [],
    this.filterStatus,
    this.errorMessage,
  });

  List<Reservation> get filteredReservations {
    if (filterStatus == null) return reservations;
    return reservations.where((r) => r.status == filterStatus).toList();
  }

  ReservationListState copyWith({
    ReservationListStatus? status,
    List<Reservation>? reservations,
    ReservationStatus? filterStatus,
    bool clearFilter = false,
    String? errorMessage,
  }) {
    return ReservationListState(
      status: status ?? this.status,
      reservations: reservations ?? this.reservations,
      filterStatus: clearFilter ? null : (filterStatus ?? this.filterStatus),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, reservations, filterStatus, errorMessage];
}
