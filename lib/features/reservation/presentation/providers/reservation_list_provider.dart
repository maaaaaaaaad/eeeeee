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

  void filterByStatuses(List<ReservationStatus> statuses) {
    state = state.copyWith(
      filterStatuses: statuses,
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
  final List<ReservationStatus> filterStatuses;
  final String? errorMessage;

  const ReservationListState({
    this.status = ReservationListStatus.initial,
    this.reservations = const [],
    this.filterStatuses = const [],
    this.errorMessage,
  });

  List<Reservation> get filteredReservations {
    if (filterStatuses.isEmpty) return reservations;
    return reservations
        .where((r) => filterStatuses.contains(r.status))
        .toList();
  }

  ReservationListState copyWith({
    ReservationListStatus? status,
    List<Reservation>? reservations,
    List<ReservationStatus>? filterStatuses,
    String? errorMessage,
  }) {
    return ReservationListState(
      status: status ?? this.status,
      reservations: reservations ?? this.reservations,
      filterStatuses: filterStatuses ?? this.filterStatuses,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, reservations, filterStatuses, errorMessage];
}
