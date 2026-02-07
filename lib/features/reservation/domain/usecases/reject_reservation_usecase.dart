import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reject_reservation_params.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation.dart';
import 'package:mobile_owner/features/reservation/domain/repositories/reservation_repository.dart';

class RejectReservationUseCase
    extends UseCase<Either<Failure, Reservation>, RejectReservationParams> {
  final ReservationRepository repository;

  RejectReservationUseCase(this.repository);

  @override
  Future<Either<Failure, Reservation>> call(RejectReservationParams params) {
    return repository.rejectReservation(params);
  }
}
