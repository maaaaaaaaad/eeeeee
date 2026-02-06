import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/home/data/models/beauty_shop_model.dart';

void main() {
  group('BeautyShopModel', () {
    test('should parse from JSON correctly', () {
      final json = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'name': 'Beautiful Salon',
        'regNum': '123-45-67890',
        'phoneNumber': '010-1234-5678',
        'address': '서울특별시 강남구',
        'latitude': 37.5665,
        'longitude': 126.9780,
        'operatingTime': {'monday': '09:00-18:00', 'tuesday': '09:00-18:00'},
        'description': '아름다운 네일샵',
        'images': ['https://example.com/img1.jpg', 'https://example.com/img2.jpg'],
        'averageRating': 4.5,
        'reviewCount': 42,
        'categories': [
          {'id': 'cat-1', 'name': '네일'},
          {'id': 'cat-2', 'name': '속눈썹'},
        ],
      };

      final model = BeautyShopModel.fromJson(json);

      expect(model.id, '550e8400-e29b-41d4-a716-446655440000');
      expect(model.name, 'Beautiful Salon');
      expect(model.regNum, '123-45-67890');
      expect(model.phoneNumber, '010-1234-5678');
      expect(model.address, '서울특별시 강남구');
      expect(model.latitude, 37.5665);
      expect(model.longitude, 126.9780);
      expect(model.operatingTime['monday'], '09:00-18:00');
      expect(model.description, '아름다운 네일샵');
      expect(model.images.length, 2);
      expect(model.averageRating, 4.5);
      expect(model.reviewCount, 42);
      expect(model.categories.length, 2);
      expect(model.categories[0].name, '네일');
    });

    test('should handle null optional fields', () {
      final json = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'name': 'Minimal Salon',
        'regNum': '111-11-11111',
        'phoneNumber': '010-0000-0000',
        'address': 'Seoul',
        'latitude': 37.0,
        'longitude': 127.0,
        'operatingTime': null,
        'description': null,
        'images': null,
        'averageRating': null,
        'reviewCount': null,
        'categories': null,
      };

      final model = BeautyShopModel.fromJson(json);

      expect(model.description, isNull);
      expect(model.images, isEmpty);
      expect(model.operatingTime, isEmpty);
      expect(model.averageRating, 0.0);
      expect(model.reviewCount, 0);
      expect(model.categories, isEmpty);
    });
  });

  group('CategorySummaryModel', () {
    test('should parse from JSON correctly', () {
      final json = {'id': 'cat-1', 'name': '네일'};

      final model = CategorySummaryModel.fromJson(json);

      expect(model.id, 'cat-1');
      expect(model.name, '네일');
    });
  });
}
