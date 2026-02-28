import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/beautishop/data/models/create_beautishop_request.dart';

void main() {
  group('CreateBeautishopRequest', () {
    test('should convert to JSON with all fields', () {
      const request = CreateBeautishopRequest(
        name: '테스트 샵',
        regNum: '1234567890',
        phoneNumber: '01012345678',
        address: '서울시 강남구',
        latitude: 37.5665,
        longitude: 126.978,
        operatingTime: {'MONDAY': '09:00-18:00'},
        shopDescription: '테스트 설명',
        shopImages: ['https://example.com/img.jpg'],
      );

      final json = request.toJson();

      expect(json['shopName'], '테스트 샵');
      expect(json['shopRegNum'], '1234567890');
      expect(json['shopPhoneNumber'], '01012345678');
      expect(json['shopAddress'], '서울시 강남구');
      expect(json['latitude'], 37.5665);
      expect(json['longitude'], 126.978);
      expect(json['operatingTime'], {'MONDAY': '09:00-18:00'});
      expect(json['shopDescription'], '테스트 설명');
      expect(json['shopImages'], ['https://example.com/img.jpg']);
    });

    test('should handle null description in JSON', () {
      const request = CreateBeautishopRequest(
        name: '테스트 샵',
        regNum: '1234567890',
        phoneNumber: '01012345678',
        address: '서울시 강남구',
        latitude: 37.5665,
        longitude: 126.978,
        operatingTime: {},
        shopImages: [],
      );

      final json = request.toJson();

      expect(json['shopDescription'], isNull);
      expect(json['shopImages'], isEmpty);
    });
  });
}
