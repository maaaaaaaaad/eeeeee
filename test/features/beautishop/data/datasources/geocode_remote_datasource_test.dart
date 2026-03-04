import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/features/beautishop/data/datasources/geocode_remote_datasource.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late GeocodeRemoteDataSourceImpl dataSource;

  setUp(() {
    mockDio = MockDio();
    dataSource = GeocodeRemoteDataSourceImpl.withDio(mockDio);
  });

  setUpAll(() {
    registerFallbackValue(Options());
  });

  group('GeocodeRemoteDataSource', () {
    const query = '서울특별시 강남구 테헤란로';

    final successResponse = {
      'status': 'OK',
      'addresses': [
        {
          'roadAddress': '서울특별시 강남구 테헤란로 123',
          'jibunAddress': '서울특별시 강남구 역삼동 456',
          'x': '126.978',
          'y': '37.5665',
        },
      ],
    };

    test('should call Naver Geocoding API with correct URL and headers',
        () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: successResponse,
            statusCode: 200,
            requestOptions: RequestOptions(),
          ));

      await dataSource.searchAddress(query);

      final captured = verify(() => mockDio.get<Map<String, dynamic>>(
            captureAny(),
            queryParameters: captureAny(named: 'queryParameters'),
            options: captureAny(named: 'options'),
          )).captured;

      final url = captured[0] as String;
      expect(url, contains('/map-geocode/v2/geocode'));

      final params = captured[1] as Map<String, dynamic>;
      expect(params['query'], query);

      final options = captured[2] as Options;
      expect(options.headers?['X-NCP-APIGW-API-KEY-ID'], isNotNull);
      expect(options.headers?['X-NCP-APIGW-API-KEY'], isNotNull);
    });

    test('should return list of GeocodeResultModel on success', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: successResponse,
            statusCode: 200,
            requestOptions: RequestOptions(),
          ));

      final results = await dataSource.searchAddress(query);

      expect(results.length, 1);
      expect(results[0].roadAddress, '서울특별시 강남구 테헤란로 123');
      expect(results[0].latitude, 37.5665);
      expect(results[0].longitude, 126.978);
    });

    test('should return empty list when no addresses found', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: {'status': 'OK', 'addresses': <dynamic>[]},
            statusCode: 200,
            requestOptions: RequestOptions(),
          ));

      final results = await dataSource.searchAddress(query);

      expect(results, isEmpty);
    });

    test('should rethrow DioException on network error', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenThrow(DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(),
          ));

      expect(
        () => dataSource.searchAddress(query),
        throwsA(isA<DioException>()),
      );
    });

    test('should rethrow DioException on server error', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenThrow(DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(),
            response: Response(
              statusCode: 500,
              requestOptions: RequestOptions(),
            ),
          ));

      expect(
        () => dataSource.searchAddress(query),
        throwsA(isA<DioException>()),
      );
    });
  });
}
