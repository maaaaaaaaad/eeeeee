import 'package:mobile_owner/core/network/api_client.dart';
import 'package:mobile_owner/features/designer/data/models/create_designer_request.dart';
import 'package:mobile_owner/features/designer/data/models/designer_model.dart';
import 'package:mobile_owner/features/designer/data/models/update_designer_request.dart';

abstract class DesignerRemoteDataSource {
  Future<DesignerModel> createDesigner(
      String shopId, CreateDesignerRequest request);
  Future<DesignerModel> getDesigner(String shopId, String designerId);
  Future<List<DesignerModel>> listDesigners(String shopId);
  Future<DesignerModel> updateDesigner(
      String shopId, String designerId, UpdateDesignerRequest request);
  Future<void> deleteDesigner(String shopId, String designerId);
}

class DesignerRemoteDataSourceImpl implements DesignerRemoteDataSource {
  final ApiClient _apiClient;

  DesignerRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<DesignerModel> createDesigner(
    String shopId,
    CreateDesignerRequest request,
  ) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/beautishops/$shopId/designers',
      data: request.toJson(),
    );
    return DesignerModel.fromJson(response.data!);
  }

  @override
  Future<DesignerModel> getDesigner(String shopId, String designerId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/beautishops/$shopId/designers/$designerId',
    );
    return DesignerModel.fromJson(response.data!);
  }

  @override
  Future<List<DesignerModel>> listDesigners(String shopId) async {
    final response = await _apiClient.get<dynamic>(
      '/api/beautishops/$shopId/designers',
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => DesignerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DesignerModel> updateDesigner(
    String shopId,
    String designerId,
    UpdateDesignerRequest request,
  ) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/api/beautishops/$shopId/designers/$designerId',
      data: request.toJson(),
    );
    return DesignerModel.fromJson(response.data!);
  }

  @override
  Future<void> deleteDesigner(String shopId, String designerId) async {
    await _apiClient
        .delete<void>('/api/beautishops/$shopId/designers/$designerId');
  }
}
