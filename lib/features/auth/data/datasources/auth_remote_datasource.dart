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
    required String emailVerificationToken,
  });
  Future<void> sendVerificationCode(String email, {String purpose = 'SIGNUP'});
  Future<String> verifyCode(String email, String code);
  Future<void> sendSmsVerificationCode(String phoneNumber);
  Future<String> verifySmsCode(String phoneNumber, String code);
  Future<void> resetPassword({required String email, required String newPassword, required String emailVerificationToken});
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
    required String emailVerificationToken,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/api/sign-up/owner',
      data: {
        'email': email,
        'password': password,
        'businessNumber': businessNumber,
        'phoneNumber': phoneNumber,
        'nickname': nickname,
        'emailVerificationToken': emailVerificationToken,
      },
    );

    return AuthTokenModel.fromJson(response.data!);
  }

  @override
  Future<void> sendVerificationCode(String email, {String purpose = 'SIGNUP'}) async {
    await apiClient.post(
      '/api/verification/send',
      data: {'target': email, 'type': 'EMAIL', 'purpose': purpose},
    );
  }

  @override
  Future<String> verifyCode(String email, String code) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/api/verification/verify',
      data: {'target': email, 'code': code, 'type': 'EMAIL'},
    );

    return response.data!['verificationToken'] as String;
  }

  @override
  Future<void> sendSmsVerificationCode(String phoneNumber) async {
    await apiClient.post(
      '/api/verification/send',
      data: {'target': phoneNumber, 'type': 'SMS'},
    );
  }

  @override
  Future<String> verifySmsCode(String phoneNumber, String code) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/api/verification/verify',
      data: {'target': phoneNumber, 'code': code, 'type': 'SMS'},
    );

    return response.data!['verificationToken'] as String;
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String newPassword,
    required String emailVerificationToken,
  }) async {
    await apiClient.post(
      '/api/auth/reset-password',
      data: {
        'email': email,
        'newPassword': newPassword,
        'emailVerificationToken': emailVerificationToken,
      },
    );
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
