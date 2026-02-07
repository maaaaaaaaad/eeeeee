import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/create_shop_params.dart';

void main() {
  group('CreateShopParams', () {
    test('should create with all required fields', () {
      final params = CreateShopParams(
        name: '테스트 샵',
        regNum: '1234567890',
        phoneNumber: '01012345678',
        address: '서울시 강남구',
        latitude: 37.5665,
        longitude: 126.978,
        operatingTime: const {'MONDAY': '09:00-18:00'},
        shopDescription: '테스트 설명',
        shopImages: const ['https://example.com/img.jpg'],
      );

      expect(params.name, '테스트 샵');
      expect(params.regNum, '1234567890');
      expect(params.phoneNumber, '01012345678');
      expect(params.address, '서울시 강남구');
      expect(params.latitude, 37.5665);
      expect(params.longitude, 126.978);
      expect(params.operatingTime, {'MONDAY': '09:00-18:00'});
      expect(params.shopDescription, '테스트 설명');
      expect(params.shopImages, ['https://example.com/img.jpg']);
    });

    test('should allow null description and empty images', () {
      final params = CreateShopParams(
        name: '테스트 샵',
        regNum: '1234567890',
        phoneNumber: '01012345678',
        address: '서울시 강남구',
        latitude: 37.5665,
        longitude: 126.978,
        operatingTime: const {},
      );

      expect(params.shopDescription, isNull);
      expect(params.shopImages, isEmpty);
    });

    test('should support value equality', () {
      final a = CreateShopParams(
        name: '테스트 샵',
        regNum: '1234567890',
        phoneNumber: '01012345678',
        address: '서울시 강남구',
        latitude: 37.5665,
        longitude: 126.978,
        operatingTime: const {},
      );
      final b = CreateShopParams(
        name: '테스트 샵',
        regNum: '1234567890',
        phoneNumber: '01012345678',
        address: '서울시 강남구',
        latitude: 37.5665,
        longitude: 126.978,
        operatingTime: const {},
      );
      expect(a, b);
    });
  });
}
