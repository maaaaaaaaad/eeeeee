import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/network/api_client.dart';
import 'package:mobile_owner/features/reservation/data/datasources/reservation_remote_datasource.dart';
import 'package:mobile_owner/features/reservation/data/models/reject_reservation_request.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation_status.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late ReservationRemoteDataSourceImpl dataSource;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = ReservationRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  final reservationJson = {
    'id': 'r-1',
    'shopId': 'shop-1',
    'memberId': 'member-1',
    'treatmentId': 'treatment-1',
    'shopName': '뷰티샵',
    'treatmentName': '젤네일',
    'treatmentPrice': 30000,
    'treatmentDuration': 60,
    'memberNickname': '홍길동',
    'reservationDate': '2024-06-15',
    'startTime': '10:00',
    'endTime': '11:00',
    'status': 'PENDING',
    'memo': null,
    'rejectionReason': null,
    'createdAt': '2024-01-01T00:00:00Z',
    'updatedAt': '2024-01-01T00:00:00Z',
  };

  group('getShopReservations', () {
    test('should GET /api/beautishops/{shopId}/reservations', () async {
      when(() => mockApiClient.get<dynamic>(
            '/api/beautishops/shop-1/reservations',
          )).thenAnswer((_) async => Response(
            data: [reservationJson],
            statusCode: 200,
            requestOptions:
                RequestOptions(path: '/api/beautishops/shop-1/reservations'),
          ));

      final result = await dataSource.getShopReservations('shop-1');

      expect(result.length, 1);
      expect(result[0].id, 'r-1');
      expect(result[0].shopName, '뷰티샵');
      verify(() => mockApiClient.get<dynamic>(
            '/api/beautishops/shop-1/reservations',
          )).called(1);
    });
  });

  group('getReservation', () {
    test('should GET /api/reservations/{id}', () async {
      when(() => mockApiClient.get<Map<String, dynamic>>(
            '/api/reservations/r-1',
          )).thenAnswer((_) async => Response(
            data: reservationJson,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/reservations/r-1'),
          ));

      final result = await dataSource.getReservation('r-1');

      expect(result.id, 'r-1');
      expect(result.status, ReservationStatus.pending);
      verify(() => mockApiClient.get<Map<String, dynamic>>(
            '/api/reservations/r-1',
          )).called(1);
    });
  });

  group('confirmReservation', () {
    test('should PATCH /api/reservations/{id}/confirm', () async {
      final confirmedJson = {...reservationJson, 'status': 'CONFIRMED'};
      when(() => mockApiClient.patch<Map<String, dynamic>>(
            '/api/reservations/r-1/confirm',
          )).thenAnswer((_) async => Response(
            data: confirmedJson,
            statusCode: 200,
            requestOptions:
                RequestOptions(path: '/api/reservations/r-1/confirm'),
          ));

      final result = await dataSource.confirmReservation('r-1');

      expect(result.status, ReservationStatus.confirmed);
      verify(() => mockApiClient.patch<Map<String, dynamic>>(
            '/api/reservations/r-1/confirm',
          )).called(1);
    });
  });

  group('rejectReservation', () {
    test('should PATCH /api/reservations/{id}/reject with body', () async {
      const request =
          RejectReservationRequest(rejectionReason: '일정이 맞지 않습니다');
      final rejectedJson = {
        ...reservationJson,
        'status': 'REJECTED',
        'rejectionReason': '일정이 맞지 않습니다',
      };

      when(() => mockApiClient.patch<Map<String, dynamic>>(
            '/api/reservations/r-1/reject',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: rejectedJson,
            statusCode: 200,
            requestOptions:
                RequestOptions(path: '/api/reservations/r-1/reject'),
          ));

      final result = await dataSource.rejectReservation('r-1', request);

      expect(result.status, ReservationStatus.rejected);
      expect(result.rejectionReason, '일정이 맞지 않습니다');
      verify(() => mockApiClient.patch<Map<String, dynamic>>(
            '/api/reservations/r-1/reject',
            data: request.toJson(),
          )).called(1);
    });
  });

  group('completeReservation', () {
    test('should PATCH /api/reservations/{id}/complete', () async {
      final completedJson = {...reservationJson, 'status': 'COMPLETED'};
      when(() => mockApiClient.patch<Map<String, dynamic>>(
            '/api/reservations/r-1/complete',
          )).thenAnswer((_) async => Response(
            data: completedJson,
            statusCode: 200,
            requestOptions:
                RequestOptions(path: '/api/reservations/r-1/complete'),
          ));

      final result = await dataSource.completeReservation('r-1');

      expect(result.status, ReservationStatus.completed);
      verify(() => mockApiClient.patch<Map<String, dynamic>>(
            '/api/reservations/r-1/complete',
          )).called(1);
    });
  });

  group('noShowReservation', () {
    test('should PATCH /api/reservations/{id}/no-show', () async {
      final noShowJson = {...reservationJson, 'status': 'NO_SHOW'};
      when(() => mockApiClient.patch<Map<String, dynamic>>(
            '/api/reservations/r-1/no-show',
          )).thenAnswer((_) async => Response(
            data: noShowJson,
            statusCode: 200,
            requestOptions:
                RequestOptions(path: '/api/reservations/r-1/no-show'),
          ));

      final result = await dataSource.noShowReservation('r-1');

      expect(result.status, ReservationStatus.noShow);
      verify(() => mockApiClient.patch<Map<String, dynamic>>(
            '/api/reservations/r-1/no-show',
          )).called(1);
    });
  });
}
