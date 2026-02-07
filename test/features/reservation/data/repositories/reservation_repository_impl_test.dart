import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/reservation/data/datasources/reservation_remote_datasource.dart';
import 'package:mobile_owner/features/reservation/data/models/reject_reservation_request.dart';
import 'package:mobile_owner/features/reservation/data/models/reservation_model.dart';
import 'package:mobile_owner/features/reservation/data/repositories/reservation_repository_impl.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reject_reservation_params.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation_status.dart';

class MockReservationRemoteDataSource extends Mock
    implements ReservationRemoteDataSource {}

void main() {
  late MockReservationRemoteDataSource mockDataSource;
  late ReservationRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockReservationRemoteDataSource();
    repository = ReservationRepositoryImpl(remoteDataSource: mockDataSource);
  });

  setUpAll(() {
    registerFallbackValue(
        const RejectReservationRequest(rejectionReason: ''));
  });

  final testModel = ReservationModel(
    id: 'r-1',
    shopId: 'shop-1',
    memberId: 'member-1',
    treatmentId: 'treatment-1',
    shopName: '뷰티샵',
    treatmentName: '젤네일',
    treatmentPrice: 30000,
    treatmentDuration: 60,
    memberNickname: '홍길동',
    reservationDate: '2024-06-15',
    startTime: '10:00',
    endTime: '11:00',
    status: ReservationStatus.pending,
    createdAt: DateTime.utc(2024, 1, 1),
    updatedAt: DateTime.utc(2024, 1, 1),
  );

  group('getShopReservations', () {
    test('should return list on success', () async {
      when(() => mockDataSource.getShopReservations('shop-1'))
          .thenAnswer((_) async => [testModel]);

      final result = await repository.getShopReservations('shop-1');

      result.fold(
        (_) => fail('should be right'),
        (reservations) {
          expect(reservations.length, 1);
          expect(reservations[0].id, 'r-1');
        },
      );
    });

    test('should return ServerFailure on error', () async {
      when(() => mockDataSource.getShopReservations('shop-1')).thenThrow(
        DioException(requestOptions: RequestOptions(path: '')),
      );

      final result = await repository.getShopReservations('shop-1');

      expect(result.isLeft(), true);
    });
  });

  group('getReservation', () {
    test('should return Reservation on success', () async {
      when(() => mockDataSource.getReservation('r-1'))
          .thenAnswer((_) async => testModel);

      final result = await repository.getReservation('r-1');

      expect(result, Right(testModel));
    });

    test('should return ServerFailure on error', () async {
      when(() => mockDataSource.getReservation('r-1')).thenThrow(
        DioException(requestOptions: RequestOptions(path: '')),
      );

      final result = await repository.getReservation('r-1');

      expect(result.isLeft(), true);
    });
  });

  group('confirmReservation', () {
    test('should return Reservation on success', () async {
      when(() => mockDataSource.confirmReservation('r-1'))
          .thenAnswer((_) async => testModel);

      final result = await repository.confirmReservation('r-1');

      expect(result, Right(testModel));
    });

    test('should return ServerFailure on error', () async {
      when(() => mockDataSource.confirmReservation('r-1')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            statusCode: 409,
            requestOptions: RequestOptions(path: ''),
            data: {'message': '이미 처리된 예약입니다'},
          ),
        ),
      );

      final result = await repository.confirmReservation('r-1');

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('should be left'),
      );
    });
  });

  group('rejectReservation', () {
    const params = RejectReservationParams(
      reservationId: 'r-1',
      rejectionReason: '일정이 맞지 않습니다',
    );

    test('should return Reservation on success', () async {
      when(() => mockDataSource.rejectReservation('r-1', any()))
          .thenAnswer((_) async => testModel);

      final result = await repository.rejectReservation(params);

      expect(result, Right(testModel));
    });

    test('should return ServerFailure on error', () async {
      when(() => mockDataSource.rejectReservation('r-1', any())).thenThrow(
        DioException(requestOptions: RequestOptions(path: '')),
      );

      final result = await repository.rejectReservation(params);

      expect(result.isLeft(), true);
    });
  });

  group('completeReservation', () {
    test('should return Reservation on success', () async {
      when(() => mockDataSource.completeReservation('r-1'))
          .thenAnswer((_) async => testModel);

      final result = await repository.completeReservation('r-1');

      expect(result, Right(testModel));
    });

    test('should return ServerFailure on error', () async {
      when(() => mockDataSource.completeReservation('r-1')).thenThrow(
        DioException(requestOptions: RequestOptions(path: '')),
      );

      final result = await repository.completeReservation('r-1');

      expect(result.isLeft(), true);
    });
  });

  group('noShowReservation', () {
    test('should return Reservation on success', () async {
      when(() => mockDataSource.noShowReservation('r-1'))
          .thenAnswer((_) async => testModel);

      final result = await repository.noShowReservation('r-1');

      expect(result, Right(testModel));
    });

    test('should return ServerFailure on error', () async {
      when(() => mockDataSource.noShowReservation('r-1')).thenThrow(
        DioException(requestOptions: RequestOptions(path: '')),
      );

      final result = await repository.noShowReservation('r-1');

      expect(result.isLeft(), true);
    });
  });
}
