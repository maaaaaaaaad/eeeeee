import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/treatment/domain/entities/treatment.dart';
import 'package:mobile_owner/features/treatment/presentation/widgets/treatment_card.dart';

void main() {
  final treatment = Treatment(
    id: 't-1',
    shopId: 'shop-1',
    name: '젤네일',
    price: 30000,
    duration: 60,
    description: '기본 젤네일 시술',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  group('TreatmentCard', () {
    testWidgets('should display treatment name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TreatmentCard(
              treatment: treatment,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('젤네일'), findsOneWidget);
    });

    testWidgets('should display formatted price', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TreatmentCard(
              treatment: treatment,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('30,000원'), findsOneWidget);
    });

    testWidgets('should display duration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TreatmentCard(
              treatment: treatment,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('60분'), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TreatmentCard(
              treatment: treatment,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TreatmentCard));
      expect(tapped, true);
    });
  });
}
