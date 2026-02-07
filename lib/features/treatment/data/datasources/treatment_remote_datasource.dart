import 'package:mobile_owner/core/network/api_client.dart';
import 'package:mobile_owner/features/treatment/data/models/create_treatment_request.dart';
import 'package:mobile_owner/features/treatment/data/models/treatment_model.dart';
import 'package:mobile_owner/features/treatment/data/models/update_treatment_request.dart';

abstract class TreatmentRemoteDataSource {
  Future<TreatmentModel> createTreatment(
      String shopId, CreateTreatmentRequest request);
  Future<TreatmentModel> getTreatment(String treatmentId);
  Future<List<TreatmentModel>> listTreatments(String shopId);
  Future<TreatmentModel> updateTreatment(
      String treatmentId, UpdateTreatmentRequest request);
  Future<void> deleteTreatment(String treatmentId);
}

class TreatmentRemoteDataSourceImpl implements TreatmentRemoteDataSource {
  final ApiClient _apiClient;

  TreatmentRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<TreatmentModel> createTreatment(
    String shopId,
    CreateTreatmentRequest request,
  ) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/beautishops/$shopId/treatments',
      data: request.toJson(),
    );
    return TreatmentModel.fromJson(response.data!);
  }

  @override
  Future<TreatmentModel> getTreatment(String treatmentId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/treatments/$treatmentId',
    );
    return TreatmentModel.fromJson(response.data!);
  }

  @override
  Future<List<TreatmentModel>> listTreatments(String shopId) async {
    final response = await _apiClient.get<dynamic>(
      '/api/beautishops/$shopId/treatments',
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => TreatmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TreatmentModel> updateTreatment(
    String treatmentId,
    UpdateTreatmentRequest request,
  ) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/api/treatments/$treatmentId',
      data: request.toJson(),
    );
    return TreatmentModel.fromJson(response.data!);
  }

  @override
  Future<void> deleteTreatment(String treatmentId) async {
    await _apiClient.delete<void>('/api/treatments/$treatmentId');
  }
}
