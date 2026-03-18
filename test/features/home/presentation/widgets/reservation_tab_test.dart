import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation_status.dart';
import 'package:mobile_owner/features/reservation/domain/usecases/get_owner_reservations_usecase.dart';
import 'package:mobile_owner/features/home/presentation/widgets/reservation_tab.dart';
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

  Widget createWidget() {
    return ProviderScope(
      overrides: [
        getOwnerReservationsUseCaseProvider.overrideWithValue(mockUseCase),
      ],
      child: const MaterialApp(
        home: Scaffold(body: ReservationTab()),
      ),
    );
  }

  group('ReservationTab', () {
    testWidgets('should show loading indicator initially', (tester) async {
      final completer = Completer<Either<Failure, List<Reservation>>>();
      when(() => mockUseCase()).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(const Right([]));
      await tester.pumpAndSettle();
    });

    testWidgets('should display empty state when no reservations',
        (tester) async {
      when(() => mockUseCase())
          .thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('예약이 없습니다'), findsOneWidget);
    });

    testWidgets('should display pending section header with count',
        (tester) async {
      when(() => mockUseCase())
          .thenAnswer((_) async => Right([pendingReservation]));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('확정 대기'), findsOneWidget);
      expect(find.textContaining('1건'), findsOneWidget);
    });

    testWidgets('should display confirmed section header with count',
        (tester) async {
      when(() => mockUseCase())
          .thenAnswer((_) async => Right([confirmedReservation]));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('확정'), findsWidgets);
      expect(find.text('김철수'), findsOneWidget);
    });

    testWidgets('should display both sections', (tester) async {
      when(() => mockUseCase()).thenAnswer(
          (_) async => Right([pendingReservation, confirmedReservation]));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('홍길동'), findsOneWidget);
      expect(find.text('김철수'), findsOneWidget);
    });

    testWidgets('should display error with retry button', (tester) async {
      when(() => mockUseCase())
          .thenAnswer((_) async => const Left(ServerFailure('서버 오류')));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('서버 오류'), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);
    });

    testWidgets('should retry on button tap', (tester) async {
      when(() => mockUseCase())
          .thenAnswer((_) async => const Left(ServerFailure('서버 오류')));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      when(() => mockUseCase())
          .thenAnswer((_) async => Right([pendingReservation]));

      await tester.tap(find.text('다시 시도'));
      await tester.pumpAndSettle();

      expect(find.text('홍길동'), findsOneWidget);
    });
  });
}
