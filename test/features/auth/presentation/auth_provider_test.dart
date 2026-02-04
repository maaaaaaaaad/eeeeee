import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/auth/domain/entities/auth_token.dart';
import 'package:mobile_owner/features/auth/domain/usecases/login_usecase.dart';
import 'package:mobile_owner/features/auth/presentation/providers/auth_provider.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late ProviderContainer container;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
  });

  tearDown(() {
    container.dispose();
  });

  setUpAll(() {
    registerFallbackValue(const LoginParams(email: '', password: ''));
  });

  const testEmail = 'owner@test.com';
  const testPassword = 'password123';
  const testAuthToken = AuthToken(
    accessToken: 'access_token',
    refreshToken: 'refresh_token',
  );

  group('AuthNotifier', () {
    test('initial state should be AuthState.initial', () {
      container = ProviderContainer(
        overrides: [
          loginUseCaseProvider.overrideWithValue(mockLoginUseCase),
        ],
      );

      final state = container.read(authNotifierProvider);

      expect(state, const AuthState.initial());
    });

    test('should emit loading then authenticated when login succeeds', () async {
      when(() => mockLoginUseCase(any()))
          .thenAnswer((_) async => const Right(testAuthToken));

      container = ProviderContainer(
        overrides: [
          loginUseCaseProvider.overrideWithValue(mockLoginUseCase),
        ],
      );

      final notifier = container.read(authNotifierProvider.notifier);

      final states = <AuthState>[];
      container.listen(authNotifierProvider, (previous, next) {
        states.add(next);
      });

      await notifier.login(testEmail, testPassword);

      expect(states, [
        const AuthState.loading(),
        const AuthState.authenticated(),
      ]);
    });

    test('should emit loading then error when login fails', () async {
      when(() => mockLoginUseCase(any()))
          .thenAnswer((_) async => const Left(AuthFailure('Invalid credentials')));

      container = ProviderContainer(
        overrides: [
          loginUseCaseProvider.overrideWithValue(mockLoginUseCase),
        ],
      );

      final notifier = container.read(authNotifierProvider.notifier);

      final states = <AuthState>[];
      container.listen(authNotifierProvider, (previous, next) {
        states.add(next);
      });

      await notifier.login(testEmail, testPassword);

      expect(states, [
        const AuthState.loading(),
        const AuthState.error('Invalid credentials'),
      ]);
    });
  });
}
