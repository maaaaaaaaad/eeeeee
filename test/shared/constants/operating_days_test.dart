import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/shared/constants/operating_days.dart';

void main() {
  group('OperatingDays', () {
    test('should contain all 7 days', () {
      expect(OperatingDays.orderedKeys.length, 7);
    });

    test('should have correct English to Korean mapping', () {
      expect(OperatingDays.toKorean['monday'], '월');
      expect(OperatingDays.toKorean['tuesday'], '화');
      expect(OperatingDays.toKorean['wednesday'], '수');
      expect(OperatingDays.toKorean['thursday'], '목');
      expect(OperatingDays.toKorean['friday'], '금');
      expect(OperatingDays.toKorean['saturday'], '토');
      expect(OperatingDays.toKorean['sunday'], '일');
    });

    test('orderedKeys should start with Monday and end with Sunday', () {
      expect(OperatingDays.orderedKeys.first, 'monday');
      expect(OperatingDays.orderedKeys.last, 'sunday');
    });

    test('toKorean should return null for invalid key', () {
      expect(OperatingDays.toKorean['INVALID'], isNull);
    });
  });
}
