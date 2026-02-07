import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation_status.dart';
import 'package:mobile_owner/features/reservation/domain/usecases/confirm_reservation_usecase.dart';
import 'package:mobile_owner/features/reservation/domain/usecases/reject_reservation_usecase.dart';
import 'package:mobile_owner/features/reservation/domain/usecases/complete_reservation_usecase.dart';
import 'package:mobile_owner/features/reservation/domain/usecases/no_show_reservation_usecase.dart';
import 'package:mobile_owner/features/reservation/presentation/pages/reservation_detail_page.dart';
import 'package:mobile_owner/features/reservation/presentation/providers/reservation_provider.dart';

class MockConfirmUseCase extends Mock implements ConfirmReservationUseCase {}

class MockRejectUseCase extends Mock implements RejectReservationUseCase {}

class MockCompleteUseCase extends Mock implements CompleteReservationUseCase {}

class MockNoShowUseCase extends Mock implements NoShowReservationUseCase {}

void main() {
  late MockConfirmUseCase mockConfirm;
  late MockRejectUseCase mockReject;
  late MockCompleteUseCase mockComplete;
  late MockNoShowUseCase mockNoShow;

  setUp(() {
    mockConfirm = MockConfirmUseCase();
    mockReject = MockRejectUseCase();
    mockComplete = MockCompleteUseCase();
    mockNoShow = MockNoShowUseCase();
  });

  final pendingReservation = Reservation(
    id: 'r-1',
    shopId: 'shop-1',
    memberId: 'member-1',
    treatmentId: 'treatment-1',
    memberNickname: '홍길동',
    treatmentName: '젤네일',
    treatmentPrice: 30000,
    treatmentDuration: 60,
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
    memberId: 'member-1',
    treatmentId: 'treatment-1',
    memberNickname: '홍길동',
    treatmentName: '젤네일',
    treatmentPrice: 30000,
    treatmentDuration: 60,
    reservationDate: '2024-06-15',
    startTime: '10:00',
    endTime: '11:00',
    status: ReservationStatus.confirmed,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  final completedReservation = Reservation(
    id: 'r-3',
    shopId: 'shop-1',
    memberId: 'member-1',
    treatmentId: 'treatment-1',
    memberNickname: '홍길동',
    treatmentName: '젤네일',
    treatmentPrice: 30000,
    treatmentDuration: 60,
    reservationDate: '2024-06-15',
    startTime: '10:00',
    endTime: '11:00',
    status: ReservationStatus.completed,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  Widget createWidget(Reservation reservation) {
    return ProviderScope(
      overrides: [
        confirmReservationUseCaseProvider.overrideWithValue(mockConfirm),
        rejectReservationUseCaseProvider.overrideWithValue(mockReject),
        completeReservationUseCaseProvider.overrideWithValue(mockComplete),
        noShowReservationUseCaseProvider.overrideWithValue(mockNoShow),
      ],
      child: MaterialApp(
        home: ReservationDetailPage(reservation: reservation),
      ),
    );
  }

  group('ReservationDetailPage', () {
    testWidgets('should display reservation details', (tester) async {
      await tester.pumpWidget(createWidget(pendingReservation));

      expect(find.text('예약 상세'), findsOneWidget);
      expect(find.text('홍길동'), findsOneWidget);
      expect(find.text('젤네일'), findsOneWidget);
      expect(find.textContaining('2024-06-15'), findsOneWidget);
      expect(find.textContaining('10:00'), findsOneWidget);
    });

    testWidgets('should show confirm and reject buttons for pending',
        (tester) async {
      await tester.pumpWidget(createWidget(pendingReservation));

      expect(find.text('확정'), findsWidgets);
      expect(find.text('거절'), findsWidgets);
    });

    testWidgets('should show complete and no-show buttons for confirmed',
        (tester) async {
      await tester.pumpWidget(createWidget(confirmedReservation));

      expect(find.text('시술 완료'), findsOneWidget);
      expect(find.text('노쇼'), findsOneWidget);
    });

    testWidgets('should show no action buttons for terminal status',
        (tester) async {
      await tester.pumpWidget(createWidget(completedReservation));

      expect(find.text('완료'), findsOneWidget);
      expect(find.text('거절'), findsNothing);
      expect(find.text('시술 완료'), findsNothing);
      expect(find.text('노쇼'), findsNothing);
    });

    testWidgets('should confirm reservation when confirm button is tapped',
        (tester) async {
      when(() => mockConfirm('r-1'))
          .thenAnswer((_) async => Right(confirmedReservation));

      await tester.pumpWidget(createWidget(pendingReservation));

      await tester.tap(find.widgetWithText(ElevatedButton, '확정'));
      await tester.pumpAndSettle();

      verify(() => mockConfirm('r-1')).called(1);
    });
  });
}
