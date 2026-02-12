import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/network/api_client.dart';
import 'package:mobile_owner/features/review/data/datasources/review_remote_datasource.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late ReviewRemoteDataSourceImpl dataSource;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = ReviewRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  final reviewsJson = {
    'items': [
      {
        'id': 'r-1',
        'shopId': 'shop-1',
        'memberId': 'member-1',
        'authorName': '홍길동',
        'rating': 5,
        'content': '좋아요',
        'images': [],
        'createdAt': '2024-06-15T10:30:00Z',
        'updatedAt': '2024-06-15T10:30:00Z',
      },
    ],
    'hasNext': true,
    'totalElements': 42,
  };

  group('getShopReviews', () {
    test('should GET /api/beautishops/{shopId}/reviews with query params',
        () async {
      when(() => mockApiClient.get<Map<String, dynamic>>(
            '/api/beautishops/shop-1/reviews',
            queryParameters: {
              'page': 0,
              'size': 20,
              'sort': 'createdAt,desc',
            },
          )).thenAnswer((_) async => Response(
            data: reviewsJson,
            statusCode: 200,
            requestOptions:
                RequestOptions(path: '/api/beautishops/shop-1/reviews'),
          ));

      final result = await dataSource.getShopReviews(
        shopId: 'shop-1',
        page: 0,
        size: 20,
        sort: 'createdAt,desc',
      );

      expect(result.items.length, 1);
      expect(result.items[0].id, 'r-1');
      expect(result.hasNext, true);
      expect(result.totalElements, 42);
      verify(() => mockApiClient.get<Map<String, dynamic>>(
            '/api/beautishops/shop-1/reviews',
            queryParameters: {
              'page': 0,
              'size': 20,
              'sort': 'createdAt,desc',
            },
          )).called(1);
    });

    test('should pass custom page and sort params', () async {
      when(() => mockApiClient.get<Map<String, dynamic>>(
            '/api/beautishops/shop-1/reviews',
            queryParameters: {
              'page': 2,
              'size': 10,
              'sort': 'rating,desc',
            },
          )).thenAnswer((_) async => Response(
            data: reviewsJson,
            statusCode: 200,
            requestOptions:
                RequestOptions(path: '/api/beautishops/shop-1/reviews'),
          ));

      await dataSource.getShopReviews(
        shopId: 'shop-1',
        page: 2,
        size: 10,
        sort: 'rating,desc',
      );

      verify(() => mockApiClient.get<Map<String, dynamic>>(
            '/api/beautishops/shop-1/reviews',
            queryParameters: {
              'page': 2,
              'size': 10,
              'sort': 'rating,desc',
            },
          )).called(1);
    });
  });
}
