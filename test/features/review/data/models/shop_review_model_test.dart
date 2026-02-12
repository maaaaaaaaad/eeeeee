import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/review/data/models/shop_review_model.dart';
import 'package:mobile_owner/features/review/domain/entities/shop_review.dart';

void main() {
  group('ShopReviewModel', () {
    test('should be a subclass of ShopReview', () {
      final model = ShopReviewModel(
        id: 'r-1',
        shopId: 'shop-1',
        memberId: 'member-1',
        images: [],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      expect(model, isA<ShopReview>());
    });

    test('should parse from JSON with all fields', () {
      final json = {
        'id': 'r-1',
        'shopId': 'shop-1',
        'shopName': '예쁜네일샵',
        'shopImage': 'https://example.com/shop.jpg',
        'memberId': 'member-1',
        'authorName': '홍길동',
        'rating': 5,
        'content': '시술이 너무 좋았어요!',
        'images': ['https://example.com/img1.jpg', 'https://example.com/img2.jpg'],
        'createdAt': '2024-06-15T10:30:00Z',
        'updatedAt': '2024-06-15T10:30:00Z',
      };

      final model = ShopReviewModel.fromJson(json);

      expect(model.id, 'r-1');
      expect(model.shopId, 'shop-1');
      expect(model.shopName, '예쁜네일샵');
      expect(model.shopImage, 'https://example.com/shop.jpg');
      expect(model.memberId, 'member-1');
      expect(model.authorName, '홍길동');
      expect(model.rating, 5);
      expect(model.content, '시술이 너무 좋았어요!');
      expect(model.images.length, 2);
      expect(model.createdAt, DateTime.utc(2024, 6, 15, 10, 30));
      expect(model.updatedAt, DateTime.utc(2024, 6, 15, 10, 30));
    });

    test('should handle null optional fields', () {
      final json = {
        'id': 'r-2',
        'shopId': 'shop-1',
        'memberId': 'member-1',
        'shopName': null,
        'shopImage': null,
        'authorName': null,
        'rating': null,
        'content': null,
        'images': null,
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      };

      final model = ShopReviewModel.fromJson(json);

      expect(model.shopName, isNull);
      expect(model.shopImage, isNull);
      expect(model.authorName, isNull);
      expect(model.rating, isNull);
      expect(model.content, isNull);
      expect(model.images, isEmpty);
    });

    test('should handle missing optional fields', () {
      final json = {
        'id': 'r-3',
        'shopId': 'shop-1',
        'memberId': 'member-1',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      };

      final model = ShopReviewModel.fromJson(json);

      expect(model.shopName, isNull);
      expect(model.rating, isNull);
      expect(model.content, isNull);
      expect(model.images, isEmpty);
    });

    test('should handle rating as num type', () {
      final json = {
        'id': 'r-1',
        'shopId': 'shop-1',
        'memberId': 'member-1',
        'rating': 4.0,
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      };

      final model = ShopReviewModel.fromJson(json);

      expect(model.rating, 4);
    });
  });
}
