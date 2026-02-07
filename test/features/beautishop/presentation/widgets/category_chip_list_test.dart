import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/category_chip_list.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';

void main() {
  group('CategoryChipList', () {
    testWidgets('should show empty message when no categories', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CategoryChipList(categories: []),
          ),
        ),
      );

      expect(find.text('설정된 카테고리 없음'), findsOneWidget);
    });

    testWidgets('should display category chips', (tester) async {
      const categories = [
        CategorySummary(id: '1', name: '네일'),
        CategorySummary(id: '2', name: '헤어'),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CategoryChipList(categories: categories),
          ),
        ),
      );

      expect(find.text('네일'), findsOneWidget);
      expect(find.text('헤어'), findsOneWidget);
      expect(find.byType(Chip), findsNWidgets(2));
    });
  });
}
