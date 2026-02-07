import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reject_reservation_params.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation_status.dart';
import 'package:mobile_owner/features/reservation/domain/usecases/confirm_reservation_usecase.dart';
import 'package:mobile_owner/features/reservation/domain/usecases/reject_reservation_usecase.dart';
import 'package:mobile_owner/features/reservation/domain/usecases/complete_reservation_usecase.dart';
import 'package:mobile_owner/features/reservation/domain/usecases/no_show_reservation_usecase.dart';
import 'package:mobile_owner/features/reservation/presentation/providers/reservation_action_provider.dart';
import 'package:mobile_owner/features/reservation/presentation/providers/reservation_provider.dart';

class MockConfirmReservationUseCase extends Mock
    implements ConfirmReservationUseCase {}

class MockRejectReservationUseCase extends Mock
    implements RejectReservationUseCase {}

class MockCompleteReservationUseCase extends Mock
    implements CompleteReservationUseCase {}

class MockNoShowReservationUseCase extends Mock
    implements NoShowReservationUseCase {}

void main() {
  late MockConfirmReservationUseCase mockConfirm;
  late MockRejectReservationUseCase mockReject;
  late MockCompleteReservationUseCase mockComplete;
  late MockNoShowReservationUseCase mockNoShow;

  setUp(() {
    mockConfirm = MockConfirmReservationUseCase();
    mockReject = MockRejectReservationUseCase();
    mockComplete = MockCompleteReservationUseCase();
    mockNoShow = MockNoShowReservationUseCase();
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
    status: ReservationStatus.confirmed,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        confirmReservationUseCaseProvider.overrideWithValue(mockConfirm),
        rejectReservationUseCaseProvider.overrideWithValue(mockReject),
        completeReservationUseCaseProvider.overrideWithValue(mockComplete),
        noShowReservationUseCaseProvider.overrideWithValue(mockNoShow),
      ],
    );
  }

  group('ReservationActionNotifier', () {
    test('initial state should be initial status', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final state = container.read(reservationActionNotifierProvider);
      expect(state.status, ReservationActionStatus.initial);
    });

    test('should confirm reservation successfully', () async {
      when(() => mockConfirm('r-1'))
          .thenAnswer((_) async => Right(testReservation));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(reservationActionNotifierProvider.notifier);
      await notifier.confirm('r-1');

      final state = container.read(reservationActionNotifierProvider);
      expect(state.status, ReservationActionStatus.success);
    });

    test('should handle confirm failure', () async {
      when(() => mockConfirm('r-1'))
          .thenAnswer((_) async => const Left(ServerFailure('확정 실패')));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(reservationActionNotifierProvider.notifier);
      await notifier.confirm('r-1');

      final state = container.read(reservationActionNotifierProvider);
      expect(state.status, ReservationActionStatus.error);
      expect(state.errorMessage, '확정 실패');
    });

    test('should reject reservation successfully', () async {
      const params = RejectReservationParams(
        reservationId: 'r-1',
        rejectionReason: '일정이 맞지 않습니다',
      );
      when(() => mockReject(params))
          .thenAnswer((_) async => Right(testReservation));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(reservationActionNotifierProvider.notifier);
      await notifier.reject(params);

      final state = container.read(reservationActionNotifierProvider);
      expect(state.status, ReservationActionStatus.success);
    });

    test('should handle reject failure', () async {
      when(() => mockReject(any()))
          .thenAnswer((_) async => const Left(ServerFailure('거절 실패')));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(reservationActionNotifierProvider.notifier);
      await notifier.reject(const RejectReservationParams(
        reservationId: 'r-1',
        rejectionReason: '사유',
      ));

      final state = container.read(reservationActionNotifierProvider);
      expect(state.status, ReservationActionStatus.error);
      expect(state.errorMessage, '거절 실패');
    });

    test('should complete reservation successfully', () async {
      when(() => mockComplete('r-1'))
          .thenAnswer((_) async => Right(testReservation));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(reservationActionNotifierProvider.notifier);
      await notifier.complete('r-1');

      final state = container.read(reservationActionNotifierProvider);
      expect(state.status, ReservationActionStatus.success);
    });

    test('should handle complete failure', () async {
      when(() => mockComplete('r-1'))
          .thenAnswer((_) async => const Left(ServerFailure('완료 실패')));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(reservationActionNotifierProvider.notifier);
      await notifier.complete('r-1');

      final state = container.read(reservationActionNotifierProvider);
      expect(state.status, ReservationActionStatus.error);
      expect(state.errorMessage, '완료 실패');
    });

    test('should mark no-show successfully', () async {
      when(() => mockNoShow('r-1'))
          .thenAnswer((_) async => Right(testReservation));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(reservationActionNotifierProvider.notifier);
      await notifier.noShow('r-1');

      final state = container.read(reservationActionNotifierProvider);
      expect(state.status, ReservationActionStatus.success);
    });

    test('should handle no-show failure', () async {
      when(() => mockNoShow('r-1'))
          .thenAnswer((_) async => const Left(ServerFailure('노쇼 처리 실패')));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(reservationActionNotifierProvider.notifier);
      await notifier.noShow('r-1');

      final state = container.read(reservationActionNotifierProvider);
      expect(state.status, ReservationActionStatus.error);
      expect(state.errorMessage, '노쇼 처리 실패');
    });
  });
}
