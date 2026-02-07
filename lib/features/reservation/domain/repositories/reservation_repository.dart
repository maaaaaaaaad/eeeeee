import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reject_reservation_params.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation.dart';

abstract class ReservationRepository {
  Future<Either<Failure, List<Reservation>>> getShopReservations(String shopId);
  Future<Either<Failure, Reservation>> getReservation(String reservationId);
  Future<Either<Failure, Reservation>> confirmReservation(String reservationId);
  Future<Either<Failure, Reservation>> rejectReservation(
      RejectReservationParams params);
  Future<Either<Failure, Reservation>> completeReservation(
      String reservationId);
  Future<Either<Failure, Reservation>> noShowReservation(String reservationId);
}
