import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/reservation/data/datasources/reservation_remote_datasource.dart';
import 'package:mobile_owner/features/reservation/data/models/reject_reservation_request.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reject_reservation_params.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation.dart';
import 'package:mobile_owner/features/reservation/domain/repositories/reservation_repository.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationRemoteDataSource _remoteDataSource;

  ReservationRepositoryImpl(
      {required ReservationRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<Reservation>>> getShopReservations(
      String shopId) async {
    try {
      final reservations =
          await _remoteDataSource.getShopReservations(shopId);
      return Right(reservations);
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.response?.data?['message']?.toString() ?? '예약 목록을 불러올 수 없습니다',
      ));
    } catch (_) {
      return const Left(ServerFailure('예약 목록을 불러올 수 없습니다'));
    }
  }

  @override
  Future<Either<Failure, Reservation>> getReservation(
      String reservationId) async {
    try {
      final reservation =
          await _remoteDataSource.getReservation(reservationId);
      return Right(reservation);
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.response?.data?['message']?.toString() ?? '예약 정보를 불러올 수 없습니다',
      ));
    } catch (_) {
      return const Left(ServerFailure('예약 정보를 불러올 수 없습니다'));
    }
  }

  @override
  Future<Either<Failure, Reservation>> confirmReservation(
      String reservationId) async {
    try {
      final reservation =
          await _remoteDataSource.confirmReservation(reservationId);
      return Right(reservation);
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.response?.data?['message']?.toString() ?? '예약 확정에 실패했습니다',
      ));
    } catch (_) {
      return const Left(ServerFailure('예약 확정에 실패했습니다'));
    }
  }

  @override
  Future<Either<Failure, Reservation>> rejectReservation(
      RejectReservationParams params) async {
    try {
      final request = RejectReservationRequest(
        rejectionReason: params.rejectionReason,
      );
      final reservation = await _remoteDataSource.rejectReservation(
          params.reservationId, request);
      return Right(reservation);
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.response?.data?['message']?.toString() ?? '예약 거절에 실패했습니다',
      ));
    } catch (_) {
      return const Left(ServerFailure('예약 거절에 실패했습니다'));
    }
  }

  @override
  Future<Either<Failure, Reservation>> completeReservation(
      String reservationId) async {
    try {
      final reservation =
          await _remoteDataSource.completeReservation(reservationId);
      return Right(reservation);
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.response?.data?['message']?.toString() ?? '시술 완료 처리에 실패했습니다',
      ));
    } catch (_) {
      return const Left(ServerFailure('시술 완료 처리에 실패했습니다'));
    }
  }

  @override
  Future<Either<Failure, Reservation>> noShowReservation(
      String reservationId) async {
    try {
      final reservation =
          await _remoteDataSource.noShowReservation(reservationId);
      return Right(reservation);
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.response?.data?['message']?.toString() ?? '노쇼 처리에 실패했습니다',
      ));
    } catch (_) {
      return const Left(ServerFailure('노쇼 처리에 실패했습니다'));
    }
  }
}
