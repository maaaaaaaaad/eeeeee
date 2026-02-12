import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/review/presentation/providers/review_list_provider.dart';
import 'package:mobile_owner/features/review/presentation/widgets/review_stats_header.dart';

void main() {
  group('ReviewStatsHeader', () {
    testWidgets('should display average rating', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewStatsHeader(
              averageRating: 4.3,
              reviewCount: 42,
              currentSort: ReviewSortType.latestFirst,
              onSortChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('4.3'), findsOneWidget);
    });

    testWidgets('should display review count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewStatsHeader(
              averageRating: 4.3,
              reviewCount: 42,
              currentSort: ReviewSortType.latestFirst,
              onSortChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.textContaining('42건'), findsOneWidget);
    });

    testWidgets('should display current sort label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewStatsHeader(
              averageRating: 4.3,
              reviewCount: 42,
              currentSort: ReviewSortType.latestFirst,
              onSortChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('최신순'), findsOneWidget);
    });

    testWidgets('should display 0.0 for zero average rating', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewStatsHeader(
              averageRating: 0.0,
              reviewCount: 0,
              currentSort: ReviewSortType.latestFirst,
              onSortChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('0.0'), findsOneWidget);
      expect(find.textContaining('0건'), findsOneWidget);
    });
  });
}
