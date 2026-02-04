import 'package:mobile_owner/core/network/api_client.dart';
import 'package:mobile_owner/features/auth/data/models/auth_token_model.dart';
import 'package:mobile_owner/features/auth/data/models/owner_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokenModel> login(String email, String password);
  Future<AuthTokenModel> signUp({
    required String email,
    required String password,
    required String businessNumber,
    required String phoneNumber,
    required String nickname,
  });
  Future<AuthTokenModel> refreshToken(String refreshToken);
  Future<void> logout();
  Future<OwnerModel> getCurrentOwner();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthTokenModel> login(String email, String password) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/api/auth/authenticate',
      data: {
        'email': email,
        'password': password,
      },
    );

    return AuthTokenModel.fromJson(response.data!);
  }

  @override
  Future<AuthTokenModel> signUp({
    required String email,
    required String password,
    required String businessNumber,
    required String phoneNumber,
    required String nickname,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/api/sign-up/owner',
      data: {
        'email': email,
        'password': password,
        'businessNumber': businessNumber,
        'phoneNumber': phoneNumber,
        'nickname': nickname,
      },
    );

    return AuthTokenModel.fromJson(response.data!);
  }

  @override
  Future<AuthTokenModel> refreshToken(String refreshToken) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/api/auth/refresh',
      data: {
        'refreshToken': refreshToken,
      },
    );

    return AuthTokenModel.fromJson(response.data!);
  }

  @override
  Future<void> logout() async {
    await apiClient.post('/api/auth/logout');
  }

  @override
  Future<OwnerModel> getCurrentOwner() async {
    final response = await apiClient.get<Map<String, dynamic>>('/api/owners/me');
    return OwnerModel.fromJson(response.data!);
  }
}
