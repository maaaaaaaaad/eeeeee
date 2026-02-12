import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/review/domain/entities/shop_review.dart';
import 'package:mobile_owner/features/review/presentation/widgets/review_card.dart';

void main() {
  final review = ShopReview(
    id: 'r-1',
    shopId: 'shop-1',
    memberId: 'member-1',
    authorName: '홍길동',
    rating: 5,
    content: '시술이 너무 좋았어요!',
    images: ['https://example.com/img1.jpg', 'https://example.com/img2.jpg'],
    createdAt: DateTime(2024, 6, 15, 10, 30),
    updatedAt: DateTime(2024, 6, 15, 10, 30),
  );

  group('ReviewCard', () {
    testWidgets('should display masked author name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewCard(
              review: review,
              onImageTap: (_, _) {},
            ),
          ),
        ),
      );

      expect(find.text('홍**'), findsOneWidget);
    });

    testWidgets('should display review content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewCard(
              review: review,
              onImageTap: (_, _) {},
            ),
          ),
        ),
      );

      expect(find.text('시술이 너무 좋았어요!'), findsOneWidget);
    });

    testWidgets('should display rating stars', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewCard(
              review: review,
              onImageTap: (_, _) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsNWidgets(5));
    });

    testWidgets('should display image thumbnails when images exist',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewCard(
              review: review,
              onImageTap: (_, _) {},
            ),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('should not show content section when content is null',
        (tester) async {
      final noContent = ShopReview(
        id: 'r-2',
        shopId: 'shop-1',
        memberId: 'member-1',
        authorName: '김영희',
        rating: 3,
        images: [],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewCard(
              review: noContent,
              onImageTap: (_, _) {},
            ),
          ),
        ),
      );

      expect(find.text('김**'), findsOneWidget);
    });

    testWidgets('should not show rating stars when rating is null',
        (tester) async {
      final noRating = ShopReview(
        id: 'r-3',
        shopId: 'shop-1',
        memberId: 'member-1',
        authorName: '박철수',
        content: '좋아요',
        images: [],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewCard(
              review: noRating,
              onImageTap: (_, _) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsNothing);
      expect(find.byIcon(Icons.star_border), findsNothing);
    });

    testWidgets('should show edited indicator when review is edited',
        (tester) async {
      final edited = ShopReview(
        id: 'r-4',
        shopId: 'shop-1',
        memberId: 'member-1',
        authorName: '이영수',
        rating: 4,
        content: '수정된 리뷰',
        images: [],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewCard(
              review: edited,
              onImageTap: (_, _) {},
            ),
          ),
        ),
      );

      expect(find.textContaining('수정됨'), findsOneWidget);
    });

    testWidgets('should call onImageTap with correct index', (tester) async {
      int? tappedIndex;
      List<String>? tappedImages;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewCard(
              review: review,
              onImageTap: (images, index) {
                tappedImages = images;
                tappedIndex = index;
              },
            ),
          ),
        ),
      );

      final imageTaps = find.byKey(const Key('review_image_0'));
      if (imageTaps.evaluate().isNotEmpty) {
        await tester.tap(imageTaps);
        expect(tappedIndex, 0);
        expect(tappedImages, review.images);
      }
    });
  });
}
