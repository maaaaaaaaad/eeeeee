import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation_status.dart';
import 'package:mobile_owner/features/reservation/domain/repositories/reservation_repository.dart';
import 'package:mobile_owner/features/reservation/domain/usecases/get_owner_reservations_usecase.dart';

class MockReservationRepository extends Mock implements ReservationRepository {}

void main() {
  late MockReservationRepository mockRepository;
  late GetOwnerReservationsUseCase useCase;

  setUp(() {
    mockRepository = MockReservationRepository();
    useCase = GetOwnerReservationsUseCase(mockRepository);
  });

  final testReservations = [
    Reservation(
      id: 'r-1',
      shopId: 'shop-1',
      memberId: 'member-1',
      treatmentId: 'treatment-1',
      memberNickname: '홍길동',
      treatmentName: '젤네일',
      reservationDate: '2024-06-15',
      startTime: '10:00',
      endTime: '11:00',
      status: ReservationStatus.pending,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
  ];

  group('GetOwnerReservationsUseCase', () {
    test('should get owner reservations via repository', () async {
      when(() => mockRepository.getOwnerReservations())
          .thenAnswer((_) async => Right(testReservations));

      final result = await useCase();

      result.fold(
        (_) => fail('should be right'),
        (reservations) => expect(reservations.length, 1),
      );
      verify(() => mockRepository.getOwnerReservations()).called(1);
    });

    test('should return failure on error', () async {
      when(() => mockRepository.getOwnerReservations())
          .thenAnswer((_) async => const Left(ServerFailure('로드 실패')));

      final result = await useCase();

      expect(result.isLeft(), true);
    });

    test('should return empty list when no reservations', () async {
      when(() => mockRepository.getOwnerReservations())
          .thenAnswer((_) async => const Right([]));

      final result = await useCase();

      result.fold(
        (_) => fail('should be right'),
        (reservations) => expect(reservations, isEmpty),
      );
    });
  });
}
