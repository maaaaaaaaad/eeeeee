import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation.dart';
import 'package:mobile_owner/features/reservation/domain/repositories/reservation_repository.dart';

class NoShowReservationUseCase
    extends UseCase<Either<Failure, Reservation>, String> {
  final ReservationRepository repository;

  NoShowReservationUseCase(this.repository);

  @override
  Future<Either<Failure, Reservation>> call(String reservationId) {
    return repository.noShowReservation(reservationId);
  }
}
