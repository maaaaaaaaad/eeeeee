import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/shared/utils/input_formatters.dart';

void main() {
  group('BusinessNumberFormatter', () {
    test('should validate business number with hyphens', () {
      expect(BusinessNumberFormatter.isValid('123-45-67890'), isTrue);
    });

    test('should validate business number without hyphens', () {
      expect(BusinessNumberFormatter.isValid('1234567890'), isTrue);
    });

    test('should reject invalid business number', () {
      expect(BusinessNumberFormatter.isValid('123-45-6789'), isFalse);
      expect(BusinessNumberFormatter.isValid('12345678901'), isFalse);
      expect(BusinessNumberFormatter.isValid('abc-de-fghij'), isFalse);
    });

    test('should strip hyphens from business number', () {
      expect(BusinessNumberFormatter.stripHyphens('123-45-67890'), equals('1234567890'));
      expect(BusinessNumberFormatter.stripHyphens('1234567890'), equals('1234567890'));
    });
  });

  group('PhoneNumberFormatter', () {
    test('should validate phone number with hyphens', () {
      expect(PhoneNumberFormatter.isValid('010-1234-5678'), isTrue);
      expect(PhoneNumberFormatter.isValid('010-123-4567'), isTrue);
    });

    test('should validate phone number without hyphens', () {
      expect(PhoneNumberFormatter.isValid('01012345678'), isTrue);
      expect(PhoneNumberFormatter.isValid('0101234567'), isTrue);
    });

    test('should reject invalid phone number', () {
      expect(PhoneNumberFormatter.isValid('02-1234-5678'), isFalse);
      expect(PhoneNumberFormatter.isValid('010-12345-678'), isFalse);
      expect(PhoneNumberFormatter.isValid('abc-defg-hijk'), isFalse);
    });

    test('should strip hyphens from phone number', () {
      expect(PhoneNumberFormatter.stripHyphens('010-1234-5678'), equals('01012345678'));
      expect(PhoneNumberFormatter.stripHyphens('01012345678'), equals('01012345678'));
    });
  });
}
