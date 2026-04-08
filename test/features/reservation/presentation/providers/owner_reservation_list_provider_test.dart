import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation_status.dart';
import 'package:mobile_owner/features/reservation/domain/usecases/get_owner_reservations_usecase.dart';
import 'package:mobile_owner/features/reservation/presentation/providers/owner_reservation_list_provider.dart';
import 'package:mobile_owner/features/reservation/presentation/providers/reservation_provider.dart';

class MockGetOwnerReservationsUseCase extends Mock
    implements GetOwnerReservationsUseCase {}

void main() {
  late MockGetOwnerReservationsUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockGetOwnerReservationsUseCase();
  });

  final pendingReservation = Reservation(
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
  );

  final confirmedReservation = Reservation(
    id: 'r-2',
    shopId: 'shop-1',
    memberId: 'member-2',
    treatmentId: 'treatment-2',
    memberNickname: '김철수',
    treatmentName: '속눈썹',
    reservationDate: '2024-06-16',
    startTime: '14:00',
    endTime: '15:30',
    status: ReservationStatus.confirmed,
    createdAt: DateTime(2024, 1, 2),
    updatedAt: DateTime(2024, 1, 2),
  );

  final completedReservation = Reservation(
    id: 'r-3',
    shopId: 'shop-1',
    memberId: 'member-3',
    treatmentId: 'treatment-1',
    memberNickname: '이영희',
    treatmentName: '젤네일',
    reservationDate: '2024-06-17',
    startTime: '11:00',
    endTime: '12:00',
    status: ReservationStatus.completed,
    createdAt: DateTime(2024, 1, 3),
    updatedAt: DateTime(2024, 1, 3),
  );

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        getOwnerReservationsUseCaseProvider.overrideWithValue(mockUseCase),
      ],
    );
  }

  group('OwnerReservationListNotifier', () {
    test('initial state should have empty reservations and not loading',
        () {
      when(() => mockUseCase())
          .thenAnswer((_) async => const Right([]));

      final container = createContainer();
      addTearDown(container.dispose);

      final state = container.read(ownerReservationListNotifierProvider);
      expect(state.reservations, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('should load reservations successfully', () async {
      final reservations = [
        pendingReservation,
        confirmedReservation,
        completedReservation,
      ];
      when(() => mockUseCase())
          .thenAnswer((_) async => Right(reservations));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(ownerReservationListNotifierProvider.notifier);
      await notifier.loadReservations();

      final state = container.read(ownerReservationListNotifierProvider);
      expect(state.reservations.length, 3);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('should handle load failure', () async {
      when(() => mockUseCase())
          .thenAnswer((_) async => const Left(ServerFailure('서버 오류')));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(ownerReservationListNotifierProvider.notifier);
      await notifier.loadReservations();

      final state = container.read(ownerReservationListNotifierProvider);
      expect(state.isLoading, false);
      expect(state.error, '서버 오류');
    });

    test('pendingReservations should filter correctly', () async {
      final reservations = [
        pendingReservation,
        confirmedReservation,
        completedReservation,
      ];
      when(() => mockUseCase())
          .thenAnswer((_) async => Right(reservations));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(ownerReservationListNotifierProvider.notifier);
      await notifier.loadReservations();

      final state = container.read(ownerReservationListNotifierProvider);
      expect(state.pendingReservations.length, 1);
      expect(state.pendingReservations[0].id, 'r-1');
    });

    test('confirmedReservations should filter correctly', () async {
      final reservations = [
        pendingReservation,
        confirmedReservation,
        completedReservation,
      ];
      when(() => mockUseCase())
          .thenAnswer((_) async => Right(reservations));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(ownerReservationListNotifierProvider.notifier);
      await notifier.loadReservations();

      final state = container.read(ownerReservationListNotifierProvider);
      expect(state.confirmedReservations.length, 1);
      expect(state.confirmedReservations[0].id, 'r-2');
    });

    test('should refresh reservations', () async {
      when(() => mockUseCase()).thenAnswer(
          (_) async => Right([pendingReservation]));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(ownerReservationListNotifierProvider.notifier);
      await notifier.loadReservations();
      await notifier.refresh();

      verify(() => mockUseCase()).called(3);
    });

    test('should return empty lists when no matching status', () async {
      when(() => mockUseCase()).thenAnswer(
          (_) async => Right([completedReservation]));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(ownerReservationListNotifierProvider.notifier);
      await notifier.loadReservations();

      final state = container.read(ownerReservationListNotifierProvider);
      expect(state.pendingReservations, isEmpty);
      expect(state.confirmedReservations, isEmpty);
    });
  });

  group('OwnerReservationListState', () {
    test('copyWith should preserve existing values', () {
      const state = OwnerReservationListState(
        isLoading: true,
        error: 'error',
      );

      final copied = state.copyWith(isLoading: false);

      expect(copied.isLoading, false);
      expect(copied.error, 'error');
    });

    test('copyWith should override values', () {
      const state = OwnerReservationListState();

      final copied = state.copyWith(
        reservations: [pendingReservation],
        isLoading: true,
        error: 'test error',
      );

      expect(copied.reservations.length, 1);
      expect(copied.isLoading, true);
      expect(copied.error, 'test error');
    });
  });
}
