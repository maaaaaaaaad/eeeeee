import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/shared/utils/validators.dart';

void main() {
  group('ShopNameValidator', () {
    test('should return error for empty name', () {
      expect(ShopNameValidator.validate(''), isNotNull);
    });

    test('should return error for name shorter than 2 characters', () {
      expect(ShopNameValidator.validate('A'), isNotNull);
    });

    test('should return null for valid name with 2 characters', () {
      expect(ShopNameValidator.validate('AB'), isNull);
    });

    test('should return null for valid name with 50 characters', () {
      final name = 'A' * 50;
      expect(ShopNameValidator.validate(name), isNull);
    });

    test('should return error for name longer than 50 characters', () {
      final name = 'A' * 51;
      expect(ShopNameValidator.validate(name), isNotNull);
    });

    test('should return error for whitespace only', () {
      expect(ShopNameValidator.validate('   '), isNotNull);
    });
  });

  group('BusinessNumberValidator', () {
    test('should return error for empty value', () {
      expect(BusinessNumberValidator.validate(''), isNotNull);
    });

    test('should return null for valid 10-digit number', () {
      expect(BusinessNumberValidator.validate('1234567890'), isNull);
    });

    test('should return null for valid hyphenated format', () {
      expect(BusinessNumberValidator.validate('123-45-67890'), isNull);
    });

    test('should return error for 9-digit number', () {
      expect(BusinessNumberValidator.validate('123456789'), isNotNull);
    });

    test('should return error for 11-digit number', () {
      expect(BusinessNumberValidator.validate('12345678901'), isNotNull);
    });

    test('should return error for non-numeric characters', () {
      expect(BusinessNumberValidator.validate('12345abcde'), isNotNull);
    });
  });

  group('PhoneNumberValidator', () {
    test('should return error for empty value', () {
      expect(PhoneNumberValidator.validate(''), isNotNull);
    });

    test('should return null for valid phone number without hyphens', () {
      expect(PhoneNumberValidator.validate('01012345678'), isNull);
    });

    test('should return null for valid phone number with hyphens', () {
      expect(PhoneNumberValidator.validate('010-1234-5678'), isNull);
    });

    test('should return error for invalid prefix', () {
      expect(PhoneNumberValidator.validate('02012345678'), isNotNull);
    });

    test('should return error for too short number', () {
      expect(PhoneNumberValidator.validate('010123'), isNotNull);
    });
  });

  group('AddressValidator', () {
    test('should return error for empty address', () {
      expect(AddressValidator.validate(''), isNotNull);
    });

    test('should return null for valid address', () {
      expect(AddressValidator.validate('서울시 강남구 역삼동 123'), isNull);
    });

    test('should return error for whitespace only', () {
      expect(AddressValidator.validate('   '), isNotNull);
    });
  });

  group('CoordinateValidator', () {
    test('should return error for empty value', () {
      expect(CoordinateValidator.validateLatitude(''), isNotNull);
      expect(CoordinateValidator.validateLongitude(''), isNotNull);
    });

    test('should return error for non-numeric value', () {
      expect(CoordinateValidator.validateLatitude('abc'), isNotNull);
      expect(CoordinateValidator.validateLongitude('abc'), isNotNull);
    });

    test('should return null for valid latitude', () {
      expect(CoordinateValidator.validateLatitude('37.5665'), isNull);
    });

    test('should return error for latitude out of range', () {
      expect(CoordinateValidator.validateLatitude('91.0'), isNotNull);
      expect(CoordinateValidator.validateLatitude('-91.0'), isNotNull);
    });

    test('should return null for valid longitude', () {
      expect(CoordinateValidator.validateLongitude('126.978'), isNull);
    });

    test('should return error for longitude out of range', () {
      expect(CoordinateValidator.validateLongitude('181.0'), isNotNull);
      expect(CoordinateValidator.validateLongitude('-181.0'), isNotNull);
    });
  });

  group('ImageUrlValidator', () {
    test('should return error for empty URL', () {
      expect(ImageUrlValidator.validate(''), isNotNull);
    });

    test('should return null for valid http URL', () {
      expect(ImageUrlValidator.validate('http://example.com/image.png'), isNull);
    });

    test('should return null for valid https URL', () {
      expect(ImageUrlValidator.validate('https://example.com/image.jpg'), isNull);
    });

    test('should return error for invalid URL', () {
      expect(ImageUrlValidator.validate('not-a-url'), isNotNull);
    });
  });
}
