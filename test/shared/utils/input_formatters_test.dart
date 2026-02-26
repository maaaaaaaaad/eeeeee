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

    test('should format business number with hyphens', () {
      expect(BusinessNumberFormatter.formatWithHyphens('1234567890'), equals('123-45-67890'));
    });

    test('should format business number with hyphens when already has hyphens', () {
      expect(BusinessNumberFormatter.formatWithHyphens('123-45-67890'), equals('123-45-67890'));
    });

    test('should return original value when business number length is invalid', () {
      expect(BusinessNumberFormatter.formatWithHyphens('12345'), equals('12345'));
      expect(BusinessNumberFormatter.formatWithHyphens('12345678901'), equals('12345678901'));
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

    test('should format 11-digit phone number with hyphens', () {
      expect(PhoneNumberFormatter.formatWithHyphens('01012345678'), equals('010-1234-5678'));
    });

    test('should format 10-digit phone number with hyphens', () {
      expect(PhoneNumberFormatter.formatWithHyphens('0101234567'), equals('010-123-4567'));
    });

    test('should format phone number that already has hyphens', () {
      expect(PhoneNumberFormatter.formatWithHyphens('010-1234-5678'), equals('010-1234-5678'));
    });

    test('should return original value when phone number length is invalid', () {
      expect(PhoneNumberFormatter.formatWithHyphens('0101234'), equals('0101234'));
      expect(PhoneNumberFormatter.formatWithHyphens('010123456789'), equals('010123456789'));
    });
  });
}
