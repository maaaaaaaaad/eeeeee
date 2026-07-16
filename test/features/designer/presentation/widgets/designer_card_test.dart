import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/designer/domain/entities/designer.dart';
import 'package:mobile_owner/features/designer/presentation/widgets/designer_card.dart';

void main() {
  final designer = Designer(
    id: 'd-1',
    shopId: 'shop-1',
    name: '김디자이너',
    nickname: '젤리',
    intro: '경력 10년',
    photoUrls: const [],
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  group('DesignerCard', () {
    testWidgets('should display designer name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DesignerCard(
              designer: designer,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('김디자이너'), findsOneWidget);
    });

    testWidgets('should display nickname', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DesignerCard(
              designer: designer,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('@젤리'), findsOneWidget);
    });

    testWidgets('should display intro', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DesignerCard(
              designer: designer,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('경력 10년'), findsOneWidget);
    });

    testWidgets('should call onEdit when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DesignerCard(
              designer: designer,
              onEdit: () => tapped = true,
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DesignerCard));
      expect(tapped, true);
    });

    testWidgets('should call onDelete when delete icon is tapped',
        (tester) async {
      var deleted = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DesignerCard(
              designer: designer,
              onEdit: () {},
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(deleted, true);
    });
  });
}
