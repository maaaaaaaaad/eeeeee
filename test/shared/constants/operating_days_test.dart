import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/shared/constants/operating_days.dart';

void main() {
  group('OperatingDays', () {
    test('should contain all 7 days', () {
      expect(OperatingDays.orderedKeys.length, 7);
    });

    test('should have correct English to Korean mapping', () {
      expect(OperatingDays.toKorean['MONDAY'], '월');
      expect(OperatingDays.toKorean['TUESDAY'], '화');
      expect(OperatingDays.toKorean['WEDNESDAY'], '수');
      expect(OperatingDays.toKorean['THURSDAY'], '목');
      expect(OperatingDays.toKorean['FRIDAY'], '금');
      expect(OperatingDays.toKorean['SATURDAY'], '토');
      expect(OperatingDays.toKorean['SUNDAY'], '일');
    });

    test('orderedKeys should start with Monday and end with Sunday', () {
      expect(OperatingDays.orderedKeys.first, 'MONDAY');
      expect(OperatingDays.orderedKeys.last, 'SUNDAY');
    });

    test('toKorean should return null for invalid key', () {
      expect(OperatingDays.toKorean['INVALID'], isNull);
    });
  });
}
