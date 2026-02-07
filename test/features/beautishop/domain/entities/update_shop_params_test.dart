import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/update_shop_params.dart';

void main() {
  group('UpdateShopParams', () {
    test('should create with all fields', () {
      final params = UpdateShopParams(
        shopId: 'shop-1',
        operatingTime: const {'MONDAY': '09:00-18:00'},
        shopDescription: '업데이트 설명',
        shopImages: const ['https://example.com/new.jpg'],
      );

      expect(params.shopId, 'shop-1');
      expect(params.operatingTime, {'MONDAY': '09:00-18:00'});
      expect(params.shopDescription, '업데이트 설명');
      expect(params.shopImages, ['https://example.com/new.jpg']);
    });

    test('should allow null description', () {
      final params = UpdateShopParams(
        shopId: 'shop-1',
        operatingTime: const {},
        shopImages: const [],
      );

      expect(params.shopDescription, isNull);
    });

    test('should support value equality', () {
      final a = UpdateShopParams(
        shopId: 'shop-1',
        operatingTime: const {},
        shopImages: const [],
      );
      final b = UpdateShopParams(
        shopId: 'shop-1',
        operatingTime: const {},
        shopImages: const [],
      );
      expect(a, b);
    });
  });
}
