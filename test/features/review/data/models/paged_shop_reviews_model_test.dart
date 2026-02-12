import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/review/data/models/paged_shop_reviews_model.dart';
import 'package:mobile_owner/features/review/domain/entities/paged_shop_reviews.dart';

void main() {
  group('PagedShopReviewsModel', () {
    test('should be a subclass of PagedShopReviews', () {
      const model = PagedShopReviewsModel(
        items: [],
        hasNext: false,
        totalElements: 0,
      );
      expect(model, isA<PagedShopReviews>());
    });

    test('should parse from JSON correctly', () {
      final json = {
        'items': [
          {
            'id': 'r-1',
            'shopId': 'shop-1',
            'memberId': 'member-1',
            'authorName': '홍길동',
            'rating': 5,
            'content': '좋아요',
            'images': ['https://example.com/img.jpg'],
            'createdAt': '2024-06-15T10:30:00Z',
            'updatedAt': '2024-06-15T10:30:00Z',
          },
          {
            'id': 'r-2',
            'shopId': 'shop-1',
            'memberId': 'member-2',
            'rating': 3,
            'images': [],
            'createdAt': '2024-06-14T10:30:00Z',
            'updatedAt': '2024-06-14T10:30:00Z',
          },
        ],
        'hasNext': true,
        'totalElements': 42,
      };

      final model = PagedShopReviewsModel.fromJson(json);

      expect(model.items.length, 2);
      expect(model.items[0].id, 'r-1');
      expect(model.items[0].authorName, '홍길동');
      expect(model.items[1].id, 'r-2');
      expect(model.hasNext, true);
      expect(model.totalElements, 42);
    });

    test('should handle empty items list', () {
      final json = {
        'items': [],
        'hasNext': false,
        'totalElements': 0,
      };

      final model = PagedShopReviewsModel.fromJson(json);

      expect(model.items, isEmpty);
      expect(model.hasNext, false);
      expect(model.totalElements, 0);
    });

    test('should handle null items as empty list', () {
      final json = {
        'items': null,
        'hasNext': false,
        'totalElements': 0,
      };

      final model = PagedShopReviewsModel.fromJson(json);

      expect(model.items, isEmpty);
    });
  });
}
