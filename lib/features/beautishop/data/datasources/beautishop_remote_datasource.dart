import 'package:mobile_owner/core/network/api_client.dart';
import 'package:mobile_owner/features/beautishop/data/models/category_model.dart';
import 'package:mobile_owner/features/beautishop/data/models/create_beautishop_request.dart';
import 'package:mobile_owner/features/beautishop/data/models/update_beautishop_request.dart';
import 'package:mobile_owner/features/home/data/models/beauty_shop_model.dart';

abstract class BeautishopRemoteDataSource {
  Future<BeautyShopModel> createShop(CreateBeautishopRequest request);
  Future<BeautyShopModel> getShop(String shopId);
  Future<BeautyShopModel> updateShop(String shopId, UpdateBeautishopRequest request);
  Future<void> deleteShop(String shopId);
  Future<List<CategoryModel>> getCategories();
  Future<void> setShopCategories(String shopId, List<String> categoryIds);
}

class BeautishopRemoteDataSourceImpl implements BeautishopRemoteDataSource {
  final ApiClient _apiClient;

  BeautishopRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<BeautyShopModel> createShop(CreateBeautishopRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/beautishops',
      data: request.toJson(),
    );
    return BeautyShopModel.fromJson(response.data!);
  }

  @override
  Future<BeautyShopModel> getShop(String shopId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/beautishops/$shopId',
    );
    return BeautyShopModel.fromJson(response.data!);
  }

  @override
  Future<BeautyShopModel> updateShop(
    String shopId,
    UpdateBeautishopRequest request,
  ) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/api/beautishops/$shopId',
      data: request.toJson(),
    );
    return BeautyShopModel.fromJson(response.data!);
  }

  @override
  Future<void> deleteShop(String shopId) async {
    await _apiClient.delete<void>('/api/beautishops/$shopId');
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiClient.get<dynamic>('/api/categories');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> setShopCategories(
    String shopId,
    List<String> categoryIds,
  ) async {
    await _apiClient.put<void>(
      '/api/beautishops/$shopId/categories',
      data: {'categoryIds': categoryIds},
    );
  }
}
