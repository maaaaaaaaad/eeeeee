import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation_status.dart';
import 'package:mobile_owner/features/reservation/presentation/providers/reservation_provider.dart';

final ownerReservationListNotifierProvider = AutoDisposeNotifierProvider<
    OwnerReservationListNotifier, OwnerReservationListState>(
  () => OwnerReservationListNotifier(),
);

class OwnerReservationListNotifier
    extends AutoDisposeNotifier<OwnerReservationListState> {
  @override
  OwnerReservationListState build() {
    return const OwnerReservationListState();
  }

  Future<void> loadReservations() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final useCase = ref.read(getOwnerReservationsUseCaseProvider);
    final result = await useCase();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (reservations) => state = state.copyWith(
        isLoading: false,
        reservations: reservations,
      ),
    );
  }

  Future<void> refresh() async {
    await loadReservations();
  }
}

class OwnerReservationListState {
  final List<Reservation> reservations;
  final bool isLoading;
  final String? error;

  const OwnerReservationListState({
    this.reservations = const [],
    this.isLoading = false,
    this.error,
  });

  List<Reservation> get pendingReservations =>
      reservations.where((r) => r.status == ReservationStatus.pending).toList();

  List<Reservation> get confirmedReservations =>
      reservations
          .where((r) => r.status == ReservationStatus.confirmed)
          .toList();

  OwnerReservationListState copyWith({
    List<Reservation>? reservations,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return OwnerReservationListState(
      reservations: reservations ?? this.reservations,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
