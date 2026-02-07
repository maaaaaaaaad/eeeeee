import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation_status.dart';
import 'package:mobile_owner/features/reservation/domain/usecases/get_shop_reservations_usecase.dart';
import 'package:mobile_owner/features/reservation/presentation/providers/reservation_list_provider.dart';
import 'package:mobile_owner/features/reservation/presentation/providers/reservation_provider.dart';

class MockGetShopReservationsUseCase extends Mock
    implements GetShopReservationsUseCase {}

void main() {
  late MockGetShopReservationsUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockGetShopReservationsUseCase();
  });

  final reservations = [
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
    Reservation(
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
    ),
    Reservation(
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
    ),
  ];

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        getShopReservationsUseCaseProvider.overrideWithValue(mockUseCase),
      ],
    );
  }

  group('ReservationListNotifier', () {
    test('initial state should be initial status', () {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => const Right([]));

      final container = createContainer();
      addTearDown(container.dispose);

      final state =
          container.read(reservationListNotifierProvider('shop-1'));
      expect(state.status, ReservationListStatus.initial);
    });

    test('should load reservations successfully', () async {
      when(() => mockUseCase('shop-1'))
          .thenAnswer((_) async => Right(reservations));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container
          .read(reservationListNotifierProvider('shop-1').notifier);
      await notifier.loadReservations();

      final state =
          container.read(reservationListNotifierProvider('shop-1'));
      expect(state.status, ReservationListStatus.loaded);
      expect(state.reservations.length, 3);
    });

    test('should handle load failure', () async {
      when(() => mockUseCase('shop-1'))
          .thenAnswer((_) async => const Left(ServerFailure('로드 실패')));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container
          .read(reservationListNotifierProvider('shop-1').notifier);
      await notifier.loadReservations();

      final state =
          container.read(reservationListNotifierProvider('shop-1'));
      expect(state.status, ReservationListStatus.error);
      expect(state.errorMessage, '로드 실패');
    });

    test('should filter by status', () async {
      when(() => mockUseCase('shop-1'))
          .thenAnswer((_) async => Right(reservations));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container
          .read(reservationListNotifierProvider('shop-1').notifier);
      await notifier.loadReservations();
      notifier.filterByStatus(ReservationStatus.pending);

      final state =
          container.read(reservationListNotifierProvider('shop-1'));
      expect(state.filterStatus, ReservationStatus.pending);
      expect(state.filteredReservations.length, 1);
      expect(state.filteredReservations[0].id, 'r-1');
    });

    test('should clear filter when null is passed', () async {
      when(() => mockUseCase('shop-1'))
          .thenAnswer((_) async => Right(reservations));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container
          .read(reservationListNotifierProvider('shop-1').notifier);
      await notifier.loadReservations();
      notifier.filterByStatus(ReservationStatus.pending);
      notifier.filterByStatus(null);

      final state =
          container.read(reservationListNotifierProvider('shop-1'));
      expect(state.filterStatus, isNull);
      expect(state.filteredReservations.length, 3);
    });

    test('should refresh reservations', () async {
      when(() => mockUseCase('shop-1'))
          .thenAnswer((_) async => Right(reservations));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container
          .read(reservationListNotifierProvider('shop-1').notifier);
      await notifier.loadReservations();
      await notifier.refresh();

      final state =
          container.read(reservationListNotifierProvider('shop-1'));
      expect(state.status, ReservationListStatus.loaded);
      verify(() => mockUseCase('shop-1')).called(2);
    });
  });
}
