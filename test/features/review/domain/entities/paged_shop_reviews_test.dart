import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/review/domain/entities/paged_shop_reviews.dart';
import 'package:mobile_owner/features/review/domain/entities/shop_review.dart';

void main() {
  group('PagedShopReviews', () {
    final reviews = [
      ShopReview(
        id: 'r-1',
        shopId: 'shop-1',
        memberId: 'member-1',
        rating: 5,
        images: [],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
      ShopReview(
        id: 'r-2',
        shopId: 'shop-1',
        memberId: 'member-2',
        rating: 3,
        images: [],
        createdAt: DateTime(2024, 1, 2),
        updatedAt: DateTime(2024, 1, 2),
      ),
    ];

    test('should create with all fields', () {
      final paged = PagedShopReviews(
        items: reviews,
        hasNext: true,
        totalElements: 42,
      );

      expect(paged.items.length, 2);
      expect(paged.hasNext, true);
      expect(paged.totalElements, 42);
    });

    test('should support value equality', () {
      final a = PagedShopReviews(
        items: reviews,
        hasNext: true,
        totalElements: 42,
      );
      final b = PagedShopReviews(
        items: reviews,
        hasNext: true,
        totalElements: 42,
      );
      expect(a, b);
    });

    test('should not be equal with different hasNext', () {
      final a = PagedShopReviews(
        items: reviews,
        hasNext: true,
        totalElements: 42,
      );
      final b = PagedShopReviews(
        items: reviews,
        hasNext: false,
        totalElements: 42,
      );
      expect(a, isNot(b));
    });

    test('should handle empty items', () {
      const paged = PagedShopReviews(
        items: [],
        hasNext: false,
        totalElements: 0,
      );

      expect(paged.items, isEmpty);
      expect(paged.hasNext, false);
      expect(paged.totalElements, 0);
    });
  });
}
