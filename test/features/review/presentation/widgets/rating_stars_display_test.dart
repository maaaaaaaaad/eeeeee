import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/review/presentation/widgets/rating_stars_display.dart';

void main() {
  group('RatingStarsDisplay', () {
    testWidgets('should display 5 filled stars for rating 5', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RatingStarsDisplay(rating: 5),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsNWidgets(5));
      expect(find.byIcon(Icons.star_border), findsNothing);
    });

    testWidgets('should display 3 filled and 2 empty stars for rating 3',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RatingStarsDisplay(rating: 3),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_border), findsNWidgets(2));
    });

    testWidgets('should display 5 empty stars for rating 0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RatingStarsDisplay(rating: 0),
          ),
        ),
      );

      expect(find.byIcon(Icons.star_border), findsNWidgets(5));
    });

    testWidgets('should use custom size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RatingStarsDisplay(rating: 3, size: 24),
          ),
        ),
      );

      final icons = tester.widgetList<Icon>(find.byType(Icon));
      for (final icon in icons) {
        expect(icon.size, 24);
      }
    });
  });
}
