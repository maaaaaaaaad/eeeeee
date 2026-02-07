import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation.dart';
import 'package:mobile_owner/features/reservation/domain/repositories/reservation_repository.dart';

class GetShopReservationsUseCase
    extends UseCase<Either<Failure, List<Reservation>>, String> {
  final ReservationRepository repository;

  GetShopReservationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Reservation>>> call(String shopId) {
    return repository.getShopReservations(shopId);
  }
}
