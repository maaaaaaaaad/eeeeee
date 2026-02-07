import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reject_reservation_params.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation_status.dart';
import 'package:mobile_owner/features/reservation/domain/repositories/reservation_repository.dart';
import 'package:mobile_owner/features/reservation/domain/usecases/get_shop_reservations_usecase.dart';
import 'package:mobile_owner/features/reservation/domain/usecases/get_reservation_usecase.dart';
import 'package:mobile_owner/features/reservation/domain/usecases/confirm_reservation_usecase.dart';
import 'package:mobile_owner/features/reservation/domain/usecases/reject_reservation_usecase.dart';
import 'package:mobile_owner/features/reservation/domain/usecases/complete_reservation_usecase.dart';
import 'package:mobile_owner/features/reservation/domain/usecases/no_show_reservation_usecase.dart';

class MockReservationRepository extends Mock implements ReservationRepository {}

void main() {
  late MockReservationRepository mockRepository;

  setUp(() {
    mockRepository = MockReservationRepository();
  });

  setUpAll(() {
    registerFallbackValue(const RejectReservationParams(
      reservationId: '',
      rejectionReason: '',
    ));
  });

  final testReservation = Reservation(
    id: 'r-1',
    shopId: 'shop-1',
    memberId: 'member-1',
    treatmentId: 'treatment-1',
    reservationDate: '2024-06-15',
    startTime: '10:00',
    endTime: '11:00',
    status: ReservationStatus.pending,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  group('GetShopReservationsUseCase', () {
    late GetShopReservationsUseCase useCase;

    setUp(() {
      useCase = GetShopReservationsUseCase(mockRepository);
    });

    test('should get shop reservations via repository', () async {
      when(() => mockRepository.getShopReservations('shop-1'))
          .thenAnswer((_) async => Right([testReservation]));

      final result = await useCase('shop-1');

      result.fold(
        (_) => fail('should be right'),
        (reservations) => expect(reservations.length, 1),
      );
      verify(() => mockRepository.getShopReservations('shop-1')).called(1);
    });

    test('should return failure on error', () async {
      when(() => mockRepository.getShopReservations('shop-1'))
          .thenAnswer((_) async => const Left(ServerFailure('로드 실패')));

      final result = await useCase('shop-1');

      expect(result.isLeft(), true);
    });
  });

  group('GetReservationUseCase', () {
    late GetReservationUseCase useCase;

    setUp(() {
      useCase = GetReservationUseCase(mockRepository);
    });

    test('should get reservation by id', () async {
      when(() => mockRepository.getReservation('r-1'))
          .thenAnswer((_) async => Right(testReservation));

      final result = await useCase('r-1');

      expect(result, Right(testReservation));
      verify(() => mockRepository.getReservation('r-1')).called(1);
    });

    test('should return failure when not found', () async {
      when(() => mockRepository.getReservation('invalid'))
          .thenAnswer((_) async => const Left(ServerFailure('예약을 찾을 수 없습니다')));

      final result = await useCase('invalid');

      expect(result.isLeft(), true);
    });
  });

  group('ConfirmReservationUseCase', () {
    late ConfirmReservationUseCase useCase;

    setUp(() {
      useCase = ConfirmReservationUseCase(mockRepository);
    });

    test('should confirm reservation via repository', () async {
      when(() => mockRepository.confirmReservation('r-1'))
          .thenAnswer((_) async => Right(testReservation));

      final result = await useCase('r-1');

      expect(result, Right(testReservation));
      verify(() => mockRepository.confirmReservation('r-1')).called(1);
    });

    test('should return failure on error', () async {
      when(() => mockRepository.confirmReservation('r-1'))
          .thenAnswer((_) async => const Left(ServerFailure('확정 실패')));

      final result = await useCase('r-1');

      expect(result.isLeft(), true);
    });
  });

  group('RejectReservationUseCase', () {
    late RejectReservationUseCase useCase;

    setUp(() {
      useCase = RejectReservationUseCase(mockRepository);
    });

    const params = RejectReservationParams(
      reservationId: 'r-1',
      rejectionReason: '일정이 맞지 않습니다',
    );

    test('should reject reservation via repository', () async {
      when(() => mockRepository.rejectReservation(params))
          .thenAnswer((_) async => Right(testReservation));

      final result = await useCase(params);

      expect(result, Right(testReservation));
      verify(() => mockRepository.rejectReservation(params)).called(1);
    });

    test('should return failure on error', () async {
      when(() => mockRepository.rejectReservation(params))
          .thenAnswer((_) async => const Left(ServerFailure('거절 실패')));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });

  group('CompleteReservationUseCase', () {
    late CompleteReservationUseCase useCase;

    setUp(() {
      useCase = CompleteReservationUseCase(mockRepository);
    });

    test('should complete reservation via repository', () async {
      when(() => mockRepository.completeReservation('r-1'))
          .thenAnswer((_) async => Right(testReservation));

      final result = await useCase('r-1');

      expect(result, Right(testReservation));
      verify(() => mockRepository.completeReservation('r-1')).called(1);
    });

    test('should return failure on error', () async {
      when(() => mockRepository.completeReservation('r-1'))
          .thenAnswer((_) async => const Left(ServerFailure('완료 실패')));

      final result = await useCase('r-1');

      expect(result.isLeft(), true);
    });
  });

  group('NoShowReservationUseCase', () {
    late NoShowReservationUseCase useCase;

    setUp(() {
      useCase = NoShowReservationUseCase(mockRepository);
    });

    test('should mark reservation as no-show via repository', () async {
      when(() => mockRepository.noShowReservation('r-1'))
          .thenAnswer((_) async => Right(testReservation));

      final result = await useCase('r-1');

      expect(result, Right(testReservation));
      verify(() => mockRepository.noShowReservation('r-1')).called(1);
    });

    test('should return failure on error', () async {
      when(() => mockRepository.noShowReservation('r-1'))
          .thenAnswer((_) async => const Left(ServerFailure('노쇼 처리 실패')));

      final result = await useCase('r-1');

      expect(result.isLeft(), true);
    });
  });
}
