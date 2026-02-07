import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile_owner/features/reservation/data/datasources/reservation_remote_datasource.dart';
import 'package:mobile_owner/features/reservation/data/repositories/reservation_repository_impl.dart';
import 'package:mobile_owner/features/reservation/domain/repositories/reservation_repository.dart';
import 'package:mobile_owner/features/reservation/domain/usecases/get_shop_reservations_usecase.dart';
import 'package:mobile_owner/features/reservation/domain/usecases/get_reservation_usecase.dart';
import 'package:mobile_owner/features/reservation/domain/usecases/confirm_reservation_usecase.dart';
import 'package:mobile_owner/features/reservation/domain/usecases/reject_reservation_usecase.dart';
import 'package:mobile_owner/features/reservation/domain/usecases/complete_reservation_usecase.dart';
import 'package:mobile_owner/features/reservation/domain/usecases/no_show_reservation_usecase.dart';

final reservationRemoteDataSourceProvider =
    Provider<ReservationRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReservationRemoteDataSourceImpl(apiClient: apiClient);
});

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  final remoteDataSource = ref.watch(reservationRemoteDataSourceProvider);
  return ReservationRepositoryImpl(remoteDataSource: remoteDataSource);
});

final getShopReservationsUseCaseProvider =
    Provider<GetShopReservationsUseCase>((ref) {
  return GetShopReservationsUseCase(ref.watch(reservationRepositoryProvider));
});

final getReservationUseCaseProvider =
    Provider<GetReservationUseCase>((ref) {
  return GetReservationUseCase(ref.watch(reservationRepositoryProvider));
});

final confirmReservationUseCaseProvider =
    Provider<ConfirmReservationUseCase>((ref) {
  return ConfirmReservationUseCase(ref.watch(reservationRepositoryProvider));
});

final rejectReservationUseCaseProvider =
    Provider<RejectReservationUseCase>((ref) {
  return RejectReservationUseCase(ref.watch(reservationRepositoryProvider));
});

final completeReservationUseCaseProvider =
    Provider<CompleteReservationUseCase>((ref) {
  return CompleteReservationUseCase(ref.watch(reservationRepositoryProvider));
});

final noShowReservationUseCaseProvider =
    Provider<NoShowReservationUseCase>((ref) {
  return NoShowReservationUseCase(ref.watch(reservationRepositoryProvider));
});
