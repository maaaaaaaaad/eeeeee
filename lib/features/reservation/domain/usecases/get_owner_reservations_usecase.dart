import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation.dart';
import 'package:mobile_owner/features/reservation/domain/repositories/reservation_repository.dart';

class GetOwnerReservationsUseCase {
  final ReservationRepository repository;

  GetOwnerReservationsUseCase(this.repository);

  Future<Either<Failure, List<Reservation>>> call() {
    return repository.getOwnerReservations();
  }
}
