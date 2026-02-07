import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/network/api_client.dart';
import 'package:mobile_owner/features/treatment/data/datasources/treatment_remote_datasource.dart';
import 'package:mobile_owner/features/treatment/data/models/create_treatment_request.dart';
import 'package:mobile_owner/features/treatment/data/models/update_treatment_request.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late TreatmentRemoteDataSourceImpl dataSource;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = TreatmentRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  final treatmentJson = {
    'id': 't-1',
    'shopId': 'shop-1',
    'name': '젤네일',
    'price': 30000,
    'duration': 60,
    'description': '기본 젤네일',
    'createdAt': '2024-01-01T00:00:00Z',
    'updatedAt': '2024-01-01T00:00:00Z',
  };

  group('createTreatment', () {
    const request = CreateTreatmentRequest(
      name: '젤네일',
      price: 30000,
      duration: 60,
      description: '기본 젤네일',
    );

    test('should POST to /api/beautishops/{shopId}/treatments', () async {
      when(() => mockApiClient.post<Map<String, dynamic>>(
            '/api/beautishops/shop-1/treatments',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: treatmentJson,
            statusCode: 201,
            requestOptions:
                RequestOptions(path: '/api/beautishops/shop-1/treatments'),
          ));

      final result = await dataSource.createTreatment('shop-1', request);

      expect(result.id, 't-1');
      expect(result.name, '젤네일');
      verify(() => mockApiClient.post<Map<String, dynamic>>(
            '/api/beautishops/shop-1/treatments',
            data: request.toJson(),
          )).called(1);
    });
  });

  group('getTreatment', () {
    test('should GET /api/treatments/{id}', () async {
      when(() => mockApiClient.get<Map<String, dynamic>>(
            '/api/treatments/t-1',
          )).thenAnswer((_) async => Response(
            data: treatmentJson,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/treatments/t-1'),
          ));

      final result = await dataSource.getTreatment('t-1');

      expect(result.id, 't-1');
      verify(() => mockApiClient.get<Map<String, dynamic>>(
            '/api/treatments/t-1',
          )).called(1);
    });
  });

  group('listTreatments', () {
    test('should GET /api/beautishops/{shopId}/treatments', () async {
      when(() => mockApiClient.get<dynamic>(
            '/api/beautishops/shop-1/treatments',
          )).thenAnswer((_) async => Response(
            data: [treatmentJson],
            statusCode: 200,
            requestOptions:
                RequestOptions(path: '/api/beautishops/shop-1/treatments'),
          ));

      final result = await dataSource.listTreatments('shop-1');

      expect(result.length, 1);
      expect(result[0].name, '젤네일');
    });
  });

  group('updateTreatment', () {
    const request = UpdateTreatmentRequest(
      name: '젤네일 수정',
      price: 35000,
      duration: 90,
    );

    test('should PUT to /api/treatments/{id}', () async {
      when(() => mockApiClient.put<Map<String, dynamic>>(
            '/api/treatments/t-1',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: treatmentJson,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/treatments/t-1'),
          ));

      final result = await dataSource.updateTreatment('t-1', request);

      expect(result.id, 't-1');
      verify(() => mockApiClient.put<Map<String, dynamic>>(
            '/api/treatments/t-1',
            data: request.toJson(),
          )).called(1);
    });
  });

  group('deleteTreatment', () {
    test('should DELETE /api/treatments/{id}', () async {
      when(() => mockApiClient.delete<void>(
            '/api/treatments/t-1',
          )).thenAnswer((_) async => Response(
            statusCode: 204,
            requestOptions: RequestOptions(path: '/api/treatments/t-1'),
          ));

      await dataSource.deleteTreatment('t-1');

      verify(() => mockApiClient.delete<void>(
            '/api/treatments/t-1',
          )).called(1);
    });
  });
}
