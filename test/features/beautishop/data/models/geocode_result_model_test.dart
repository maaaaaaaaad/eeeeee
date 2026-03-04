import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/beautishop/data/models/geocode_result_model.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/geocode_result.dart';

void main() {
  group('GeocodeResultModel', () {
    test('should parse from Naver Geocoding API response', () {
      final json = {
        'roadAddress': '서울특별시 강남구 테헤란로 123',
        'jibunAddress': '서울특별시 강남구 역삼동 456',
        'x': '126.978',
        'y': '37.5665',
      };

      final model = GeocodeResultModel.fromJson(json);

      expect(model.roadAddress, '서울특별시 강남구 테헤란로 123');
      expect(model.jibunAddress, '서울특별시 강남구 역삼동 456');
      expect(model.latitude, 37.5665);
      expect(model.longitude, 126.978);
    });

    test('should handle empty roadAddress', () {
      final json = {
        'roadAddress': '',
        'jibunAddress': '서울특별시 강남구 역삼동 456',
        'x': '126.978',
        'y': '37.5665',
      };

      final model = GeocodeResultModel.fromJson(json);

      expect(model.roadAddress, '');
      expect(model.jibunAddress, '서울특별시 강남구 역삼동 456');
    });

    test('should be a GeocodeResult', () {
      final json = {
        'roadAddress': '서울특별시 강남구 테헤란로 123',
        'jibunAddress': '서울특별시 강남구 역삼동 456',
        'x': '126.978',
        'y': '37.5665',
      };

      final model = GeocodeResultModel.fromJson(json);

      expect(model, isA<GeocodeResult>());
    });

    test('should parse list from API response', () {
      final apiResponse = {
        'status': 'OK',
        'addresses': [
          {
            'roadAddress': '서울특별시 강남구 테헤란로 123',
            'jibunAddress': '서울특별시 강남구 역삼동 456',
            'x': '126.978',
            'y': '37.5665',
          },
          {
            'roadAddress': '서울특별시 서초구 서초대로 789',
            'jibunAddress': '서울특별시 서초구 서초동 100',
            'x': '127.0324',
            'y': '37.4837',
          },
        ],
      };

      final results = GeocodeResultModel.fromApiResponse(apiResponse);

      expect(results.length, 2);
      expect(results[0].roadAddress, '서울특별시 강남구 테헤란로 123');
      expect(results[1].roadAddress, '서울특별시 서초구 서초대로 789');
    });

    test('should return empty list when addresses is null', () {
      final apiResponse = {
        'status': 'OK',
        'addresses': null,
      };

      final results = GeocodeResultModel.fromApiResponse(apiResponse);

      expect(results, isEmpty);
    });

    test('should return empty list when addresses is empty', () {
      final apiResponse = {
        'status': 'OK',
        'addresses': <dynamic>[],
      };

      final results = GeocodeResultModel.fromApiResponse(apiResponse);

      expect(results, isEmpty);
    });
  });
}
