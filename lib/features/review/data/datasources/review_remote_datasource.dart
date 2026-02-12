import 'package:mobile_owner/core/network/api_client.dart';
import 'package:mobile_owner/features/review/data/models/paged_shop_reviews_model.dart';

abstract class ReviewRemoteDataSource {
  Future<PagedShopReviewsModel> getShopReviews({
    required String shopId,
    required int page,
    required int size,
    required String sort,
  });
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final ApiClient _apiClient;

  ReviewRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<PagedShopReviewsModel> getShopReviews({
    required String shopId,
    required int page,
    required int size,
    required String sort,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/beautishops/$shopId/reviews',
      queryParameters: {
        'page': page,
        'size': size,
        'sort': sort,
      },
    );
    return PagedShopReviewsModel.fromJson(response.data!);
  }
}
