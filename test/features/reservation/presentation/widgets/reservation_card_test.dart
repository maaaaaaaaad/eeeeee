import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation_status.dart';
import 'package:mobile_owner/features/reservation/presentation/widgets/reservation_card.dart';

void main() {
  final reservation = Reservation(
    id: 'r-1',
    shopId: 'shop-1',
    memberId: 'member-1',
    treatmentId: 'treatment-1',
    designerId: 'designer-1',
    designerName: '김디자이너',
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

  final reservationWithoutDesigner = Reservation(
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
    status: ReservationStatus.pending,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  group('ReservationCard', () {
    testWidgets('should display member nickname', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReservationCard(
              reservation: reservation,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('홍길동'), findsOneWidget);
    });

    testWidgets('should display treatment name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReservationCard(
              reservation: reservation,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('젤네일'), findsOneWidget);
    });

    testWidgets('should display reservation date and time', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReservationCard(
              reservation: reservation,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('2024-06-15'), findsOneWidget);
      expect(find.textContaining('10:00'), findsOneWidget);
    });

    testWidgets('should display status badge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReservationCard(
              reservation: reservation,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('대기중'), findsOneWidget);
    });

    testWidgets('should display designer name when present', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReservationCard(
              reservation: reservation,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('디자이너 김디자이너'), findsOneWidget);
    });

    testWidgets('should not render designer row when absent', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReservationCard(
              reservation: reservationWithoutDesigner,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('디자이너'), findsNothing);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReservationCard(
              reservation: reservation,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ReservationCard));
      expect(tapped, true);
    });
  });
}
