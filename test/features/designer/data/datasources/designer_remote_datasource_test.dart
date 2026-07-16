import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/network/api_client.dart';
import 'package:mobile_owner/features/designer/data/datasources/designer_remote_datasource.dart';
import 'package:mobile_owner/features/designer/data/models/create_designer_request.dart';
import 'package:mobile_owner/features/designer/data/models/update_designer_request.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late DesignerRemoteDataSourceImpl dataSource;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = DesignerRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  final designerJson = {
    'id': 'd-1',
    'shopId': 'shop-1',
    'name': '김디자이너',
    'nickname': '젤리',
    'intro': '경력 10년',
    'photoUrls': ['https://cdn/1.jpg'],
    'createdAt': '2024-01-01T00:00:00Z',
    'updatedAt': '2024-01-01T00:00:00Z',
  };

  group('createDesigner', () {
    const request = CreateDesignerRequest(
      name: '김디자이너',
      nickname: '젤리',
      intro: '경력 10년',
      photoUrls: ['https://cdn/1.jpg'],
    );

    test('should POST to /api/beautishops/{shopId}/designers', () async {
      when(() => mockApiClient.post<Map<String, dynamic>>(
            '/api/beautishops/shop-1/designers',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: designerJson,
            statusCode: 201,
            requestOptions:
                RequestOptions(path: '/api/beautishops/shop-1/designers'),
          ));

      final result = await dataSource.createDesigner('shop-1', request);

      expect(result.id, 'd-1');
      expect(result.name, '김디자이너');
      verify(() => mockApiClient.post<Map<String, dynamic>>(
            '/api/beautishops/shop-1/designers',
            data: request.toJson(),
          )).called(1);
    });
  });

  group('getDesigner', () {
    test('should GET /api/beautishops/{shopId}/designers/{id}', () async {
      when(() => mockApiClient.get<Map<String, dynamic>>(
            '/api/beautishops/shop-1/designers/d-1',
          )).thenAnswer((_) async => Response(
            data: designerJson,
            statusCode: 200,
            requestOptions: RequestOptions(
                path: '/api/beautishops/shop-1/designers/d-1'),
          ));

      final result = await dataSource.getDesigner('shop-1', 'd-1');

      expect(result.id, 'd-1');
    });
  });

  group('listDesigners', () {
    test('should GET /api/beautishops/{shopId}/designers', () async {
      when(() => mockApiClient.get<dynamic>(
            '/api/beautishops/shop-1/designers',
          )).thenAnswer((_) async => Response(
            data: [designerJson],
            statusCode: 200,
            requestOptions:
                RequestOptions(path: '/api/beautishops/shop-1/designers'),
          ));

      final result = await dataSource.listDesigners('shop-1');

      expect(result.length, 1);
      expect(result[0].name, '김디자이너');
    });
  });

  group('updateDesigner', () {
    const request = UpdateDesignerRequest(name: '수정');

    test('should PATCH /api/beautishops/{shopId}/designers/{id}', () async {
      when(() => mockApiClient.patch<Map<String, dynamic>>(
            '/api/beautishops/shop-1/designers/d-1',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: designerJson,
            statusCode: 200,
            requestOptions: RequestOptions(
                path: '/api/beautishops/shop-1/designers/d-1'),
          ));

      final result = await dataSource.updateDesigner('shop-1', 'd-1', request);

      expect(result.id, 'd-1');
      verify(() => mockApiClient.patch<Map<String, dynamic>>(
            '/api/beautishops/shop-1/designers/d-1',
            data: request.toJson(),
          )).called(1);
    });
  });

  group('deleteDesigner', () {
    test('should DELETE /api/beautishops/{shopId}/designers/{id}', () async {
      when(() => mockApiClient.delete<void>(
            '/api/beautishops/shop-1/designers/d-1',
          )).thenAnswer((_) async => Response(
            statusCode: 204,
            requestOptions: RequestOptions(
                path: '/api/beautishops/shop-1/designers/d-1'),
          ));

      await dataSource.deleteDesigner('shop-1', 'd-1');

      verify(() => mockApiClient.delete<void>(
            '/api/beautishops/shop-1/designers/d-1',
          )).called(1);
    });
  });
}
