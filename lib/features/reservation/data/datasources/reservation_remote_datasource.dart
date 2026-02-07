import 'package:mobile_owner/core/network/api_client.dart';
import 'package:mobile_owner/features/reservation/data/models/reject_reservation_request.dart';
import 'package:mobile_owner/features/reservation/data/models/reservation_model.dart';

abstract class ReservationRemoteDataSource {
  Future<List<ReservationModel>> getShopReservations(String shopId);
  Future<ReservationModel> getReservation(String reservationId);
  Future<ReservationModel> confirmReservation(String reservationId);
  Future<ReservationModel> rejectReservation(
      String reservationId, RejectReservationRequest request);
  Future<ReservationModel> completeReservation(String reservationId);
  Future<ReservationModel> noShowReservation(String reservationId);
}

class ReservationRemoteDataSourceImpl implements ReservationRemoteDataSource {
  final ApiClient _apiClient;

  ReservationRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<ReservationModel>> getShopReservations(String shopId) async {
    final response = await _apiClient.get<dynamic>(
      '/api/beautishops/$shopId/reservations',
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => ReservationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ReservationModel> getReservation(String reservationId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/reservations/$reservationId',
    );
    return ReservationModel.fromJson(response.data!);
  }

  @override
  Future<ReservationModel> confirmReservation(String reservationId) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/api/reservations/$reservationId/confirm',
    );
    return ReservationModel.fromJson(response.data!);
  }

  @override
  Future<ReservationModel> rejectReservation(
    String reservationId,
    RejectReservationRequest request,
  ) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/api/reservations/$reservationId/reject',
      data: request.toJson(),
    );
    return ReservationModel.fromJson(response.data!);
  }

  @override
  Future<ReservationModel> completeReservation(String reservationId) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/api/reservations/$reservationId/complete',
    );
    return ReservationModel.fromJson(response.data!);
  }

  @override
  Future<ReservationModel> noShowReservation(String reservationId) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/api/reservations/$reservationId/no-show',
    );
    return ReservationModel.fromJson(response.data!);
  }
}
