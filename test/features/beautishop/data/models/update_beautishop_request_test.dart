import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/beautishop/data/models/update_beautishop_request.dart';

void main() {
  group('UpdateBeautishopRequest', () {
    test('should convert to JSON with all fields', () {
      const request = UpdateBeautishopRequest(
        operatingTime: {'MONDAY': '10:00-20:00'},
        shopDescription: '업데이트 설명',
        shopImages: ['https://example.com/new.jpg'],
      );

      final json = request.toJson();

      expect(json['operatingTime'], {'MONDAY': '10:00-20:00'});
      expect(json['shopDescription'], '업데이트 설명');
      expect(json['shopImages'], ['https://example.com/new.jpg']);
    });

    test('should handle null description in JSON', () {
      const request = UpdateBeautishopRequest(
        operatingTime: {},
        shopImages: [],
      );

      final json = request.toJson();

      expect(json['shopDescription'], isNull);
    });
  });
}
