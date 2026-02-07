import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/network/api_client.dart';
import 'package:mobile_owner/features/beautishop/data/datasources/beautishop_remote_datasource.dart';
import 'package:mobile_owner/features/beautishop/data/models/create_beautishop_request.dart';
import 'package:mobile_owner/features/beautishop/data/models/update_beautishop_request.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late BeautishopRemoteDataSourceImpl dataSource;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = BeautishopRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  final shopJson = {
    'id': 'shop-1',
    'name': '테스트 샵',
    'regNum': '1234567890',
    'phoneNumber': '01012345678',
    'address': '서울시 강남구',
    'latitude': 37.5665,
    'longitude': 126.978,
    'operatingTime': {'MONDAY': '09:00-18:00'},
    'description': null,
    'images': <dynamic>[],
    'averageRating': 0.0,
    'reviewCount': 0,
    'categories': <dynamic>[],
  };

  group('createShop', () {
    const request = CreateBeautishopRequest(
      name: '테스트 샵',
      regNum: '1234567890',
      phoneNumber: '01012345678',
      address: '서울시 강남구',
      latitude: 37.5665,
      longitude: 126.978,
      operatingTime: {'MONDAY': '09:00-18:00'},
      shopImages: [],
    );

    test('should POST to /api/beautishops and return BeautyShopModel', () async {
      when(() => mockApiClient.post<Map<String, dynamic>>(
            '/api/beautishops',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: shopJson,
            statusCode: 201,
            requestOptions: RequestOptions(path: '/api/beautishops'),
          ));

      final result = await dataSource.createShop(request);

      expect(result.id, 'shop-1');
      expect(result.name, '테스트 샵');
      verify(() => mockApiClient.post<Map<String, dynamic>>(
            '/api/beautishops',
            data: request.toJson(),
          )).called(1);
    });
  });

  group('getShop', () {
    test('should GET /api/beautishops/{id} and return BeautyShopModel', () async {
      when(() => mockApiClient.get<Map<String, dynamic>>(
            '/api/beautishops/shop-1',
          )).thenAnswer((_) async => Response(
            data: shopJson,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/beautishops/shop-1'),
          ));

      final result = await dataSource.getShop('shop-1');

      expect(result.id, 'shop-1');
      verify(() => mockApiClient.get<Map<String, dynamic>>(
            '/api/beautishops/shop-1',
          )).called(1);
    });
  });

  group('updateShop', () {
    const request = UpdateBeautishopRequest(
      operatingTime: {'MONDAY': '10:00-20:00'},
      shopImages: [],
    );

    test('should PUT to /api/beautishops/{id} and return BeautyShopModel', () async {
      when(() => mockApiClient.put<Map<String, dynamic>>(
            '/api/beautishops/shop-1',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: shopJson,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/beautishops/shop-1'),
          ));

      final result = await dataSource.updateShop('shop-1', request);

      expect(result.id, 'shop-1');
      verify(() => mockApiClient.put<Map<String, dynamic>>(
            '/api/beautishops/shop-1',
            data: request.toJson(),
          )).called(1);
    });
  });

  group('deleteShop', () {
    test('should DELETE /api/beautishops/{id}', () async {
      when(() => mockApiClient.delete<void>(
            '/api/beautishops/shop-1',
          )).thenAnswer((_) async => Response(
            statusCode: 204,
            requestOptions: RequestOptions(path: '/api/beautishops/shop-1'),
          ));

      await dataSource.deleteShop('shop-1');

      verify(() => mockApiClient.delete<void>(
            '/api/beautishops/shop-1',
          )).called(1);
    });
  });

  group('getCategories', () {
    test('should GET /api/categories and return list of CategoryModel', () async {
      when(() => mockApiClient.get<dynamic>(
            '/api/categories',
          )).thenAnswer((_) async => Response(
            data: [
              {'id': '1', 'name': '네일'},
              {'id': '2', 'name': '헤어'},
            ],
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/categories'),
          ));

      final result = await dataSource.getCategories();

      expect(result.length, 2);
      expect(result[0].name, '네일');
      expect(result[1].name, '헤어');
    });
  });

  group('setShopCategories', () {
    test('should PUT to /api/beautishops/{id}/categories', () async {
      when(() => mockApiClient.put<void>(
            '/api/beautishops/shop-1/categories',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/beautishops/shop-1/categories'),
          ));

      await dataSource.setShopCategories('shop-1', ['1', '2']);

      verify(() => mockApiClient.put<void>(
            '/api/beautishops/shop-1/categories',
            data: {'categoryIds': ['1', '2']},
          )).called(1);
    });
  });
}
