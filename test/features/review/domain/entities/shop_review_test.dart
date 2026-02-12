import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/review/domain/entities/shop_review.dart';

void main() {
  group('ShopReview', () {
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

    test('should create with all required fields', () {
      expect(review.id, 'r-1');
      expect(review.shopId, 'shop-1');
      expect(review.memberId, 'member-1');
      expect(review.authorName, '홍길동');
      expect(review.rating, 5);
      expect(review.content, '시술이 너무 좋았어요!');
      expect(review.images.length, 2);
    });

    test('should allow null optional fields', () {
      final minimal = ShopReview(
        id: 'r-2',
        shopId: 'shop-1',
        memberId: 'member-1',
        images: [],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(minimal.authorName, isNull);
      expect(minimal.rating, isNull);
      expect(minimal.content, isNull);
      expect(minimal.shopName, isNull);
      expect(minimal.shopImage, isNull);
      expect(minimal.images, isEmpty);
    });

    test('should support value equality by id', () {
      final a = ShopReview(
        id: 'r-1',
        shopId: 'shop-1',
        memberId: 'member-1',
        rating: 5,
        images: [],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      final b = ShopReview(
        id: 'r-1',
        shopId: 'shop-1',
        memberId: 'member-1',
        rating: 3,
        images: [],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      expect(a, b);
    });

    test('should not be equal with different ids', () {
      final a = ShopReview(
        id: 'r-1',
        shopId: 'shop-1',
        memberId: 'member-1',
        images: [],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      final b = ShopReview(
        id: 'r-2',
        shopId: 'shop-1',
        memberId: 'member-1',
        images: [],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      expect(a, isNot(b));
    });

    test('isEdited should return true when updatedAt differs from createdAt',
        () {
      final edited = ShopReview(
        id: 'r-1',
        shopId: 'shop-1',
        memberId: 'member-1',
        images: [],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );
      expect(edited.isEdited, true);
    });

    test('isEdited should return false when updatedAt equals createdAt', () {
      expect(review.isEdited, false);
    });

    test('maskedAuthorName should mask name keeping first character', () {
      expect(review.maskedAuthorName, '홍**');
    });

    test('maskedAuthorName should return empty when authorName is null', () {
      final noName = ShopReview(
        id: 'r-1',
        shopId: 'shop-1',
        memberId: 'member-1',
        images: [],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      expect(noName.maskedAuthorName, '');
    });

    test('maskedAuthorName should handle single character name', () {
      final singleChar = ShopReview(
        id: 'r-1',
        shopId: 'shop-1',
        memberId: 'member-1',
        authorName: '홍',
        images: [],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      expect(singleChar.maskedAuthorName, '홍');
    });

    test('hasContent should return true when content is not null or empty', () {
      expect(review.hasContent, true);
    });

    test('hasContent should return false when content is null', () {
      final noContent = ShopReview(
        id: 'r-1',
        shopId: 'shop-1',
        memberId: 'member-1',
        images: [],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      expect(noContent.hasContent, false);
    });

    test('hasContent should return false when content is empty', () {
      final emptyContent = ShopReview(
        id: 'r-1',
        shopId: 'shop-1',
        memberId: 'member-1',
        content: '',
        images: [],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      expect(emptyContent.hasContent, false);
    });
  });
}
