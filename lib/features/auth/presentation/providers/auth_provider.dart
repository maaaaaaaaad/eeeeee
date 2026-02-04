import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/config/env_config.dart';
import 'package:mobile_owner/core/network/api_client.dart';
import 'package:mobile_owner/core/network/auth_interceptor.dart';
import 'package:mobile_owner/core/storage/secure_token_storage.dart';
import 'package:mobile_owner/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mobile_owner/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mobile_owner/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_owner/features/auth/domain/usecases/login_usecase.dart';

final tokenStorageProvider = Provider<SecureTokenStorage>((ref) {
  return SecureTokenStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  final authInterceptor = AuthInterceptor(tokenProvider: tokenStorage);
  return ApiClient(
    baseUrl: EnvConfig.apiBaseUrl,
    authInterceptor: authInterceptor,
  );
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSourceImpl(apiClient: apiClient);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    tokenStorage: tokenStorage,
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState.initial();
  }

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();

    final loginUseCase = ref.read(loginUseCaseProvider);
    final result = await loginUseCase(LoginParams(
      email: email,
      password: password,
    ));

    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (token) => state = const AuthState.authenticated(),
    );
  }

  void logout() {
    state = const AuthState.initial();
  }
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;

  const AuthState._({
    required this.status,
    this.errorMessage,
  });

  const AuthState.initial() : this._(status: AuthStatus.initial);
  const AuthState.loading() : this._(status: AuthStatus.loading);
  const AuthState.authenticated() : this._(status: AuthStatus.authenticated);
  const AuthState.error(String message)
      : this._(status: AuthStatus.error, errorMessage: message);

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get hasError => status == AuthStatus.error;

  @override
  List<Object?> get props => [status, errorMessage];
}

enum AuthStatus {
  initial,
  loading,
  authenticated,
  error,
}
