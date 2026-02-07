import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation_status.dart';
import 'package:mobile_owner/features/reservation/domain/usecases/get_shop_reservations_usecase.dart';
import 'package:mobile_owner/features/reservation/presentation/pages/reservation_list_page.dart';
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
  ];

  Widget createWidget() {
    return ProviderScope(
      overrides: [
        getShopReservationsUseCaseProvider.overrideWithValue(mockUseCase),
      ],
      child: const MaterialApp(
        home: ReservationListPage(shopId: 'shop-1'),
      ),
    );
  }

  group('ReservationListPage', () {
    testWidgets('should display app bar title', (tester) async {
      when(() => mockUseCase('shop-1'))
          .thenAnswer((_) async => Right(reservations));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('예약 관리'), findsOneWidget);
    });

    testWidgets('should display reservation cards when loaded', (tester) async {
      when(() => mockUseCase('shop-1'))
          .thenAnswer((_) async => Right(reservations));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('홍길동'), findsOneWidget);
      expect(find.text('김철수'), findsOneWidget);
    });

    testWidgets('should display empty message when no reservations',
        (tester) async {
      when(() => mockUseCase('shop-1'))
          .thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('예약이 없습니다'), findsOneWidget);
    });

    testWidgets('should display error message on failure', (tester) async {
      when(() => mockUseCase('shop-1'))
          .thenAnswer((_) async => const Left(ServerFailure('로드 실패')));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('로드 실패'), findsOneWidget);
    });

    testWidgets('should display filter tabs', (tester) async {
      when(() => mockUseCase('shop-1'))
          .thenAnswer((_) async => Right(reservations));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('전체'), findsOneWidget);
      expect(find.text('대기중'), findsWidgets);
      expect(find.text('확정'), findsWidgets);
    });
  });
}
