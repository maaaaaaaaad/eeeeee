import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/geocode_result.dart';

void main() {
  group('GeocodeResult', () {
    test('should create with all required fields', () {
      const result = GeocodeResult(
        roadAddress: '서울특별시 강남구 테헤란로 123',
        jibunAddress: '서울특별시 강남구 역삼동 456',
        latitude: 37.5665,
        longitude: 126.978,
      );

      expect(result.roadAddress, '서울특별시 강남구 테헤란로 123');
      expect(result.jibunAddress, '서울특별시 강남구 역삼동 456');
      expect(result.latitude, 37.5665);
      expect(result.longitude, 126.978);
    });

    test('should support value equality', () {
      const a = GeocodeResult(
        roadAddress: '서울특별시 강남구 테헤란로 123',
        jibunAddress: '서울특별시 강남구 역삼동 456',
        latitude: 37.5665,
        longitude: 126.978,
      );
      const b = GeocodeResult(
        roadAddress: '서울특별시 강남구 테헤란로 123',
        jibunAddress: '서울특별시 강남구 역삼동 456',
        latitude: 37.5665,
        longitude: 126.978,
      );

      expect(a, b);
    });

    test('should not be equal when fields differ', () {
      const a = GeocodeResult(
        roadAddress: '서울특별시 강남구 테헤란로 123',
        jibunAddress: '서울특별시 강남구 역삼동 456',
        latitude: 37.5665,
        longitude: 126.978,
      );
      const b = GeocodeResult(
        roadAddress: '서울특별시 서초구 서초대로 789',
        jibunAddress: '서울특별시 서초구 서초동 100',
        latitude: 37.4837,
        longitude: 127.0324,
      );

      expect(a, isNot(b));
    });

    test('should return correct displayAddress preferring roadAddress', () {
      const result = GeocodeResult(
        roadAddress: '서울특별시 강남구 테헤란로 123',
        jibunAddress: '서울특별시 강남구 역삼동 456',
        latitude: 37.5665,
        longitude: 126.978,
      );

      expect(result.displayAddress, '서울특별시 강남구 테헤란로 123');
    });

    test('should return jibunAddress when roadAddress is empty', () {
      const result = GeocodeResult(
        roadAddress: '',
        jibunAddress: '서울특별시 강남구 역삼동 456',
        latitude: 37.5665,
        longitude: 126.978,
      );

      expect(result.displayAddress, '서울특별시 강남구 역삼동 456');
    });
  });
}
