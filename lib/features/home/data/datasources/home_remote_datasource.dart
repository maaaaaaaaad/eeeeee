import 'package:mobile_owner/core/network/api_client.dart';
import 'package:mobile_owner/features/auth/data/models/owner_model.dart';
import 'package:mobile_owner/features/home/data/models/beauty_shop_model.dart';

abstract class HomeRemoteDataSource {
  Future<OwnerModel> getMyProfile();
  Future<List<BeautyShopModel>> getMyShops();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiClient _apiClient;

  HomeRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<OwnerModel> getMyProfile() async {
    final response = await _apiClient.get('/api/owners/me');
    return OwnerModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<BeautyShopModel>> getMyShops() async {
    final response = await _apiClient.get('/api/owners/me/beautishops');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => BeautyShopModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
