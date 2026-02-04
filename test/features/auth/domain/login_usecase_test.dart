import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/auth/domain/entities/auth_token.dart';
import 'package:mobile_owner/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_owner/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  const testEmail = 'owner@test.com';
  const testPassword = 'password123';
  const testAuthToken = AuthToken(
    accessToken: 'access_token_123',
    refreshToken: 'refresh_token_123',
  );

  group('LoginUseCase', () {
    test('should return AuthToken when login is successful', () async {
      when(() => mockRepository.login(testEmail, testPassword))
          .thenAnswer((_) async => const Right(testAuthToken));

      final result = await useCase(LoginParams(
        email: testEmail,
        password: testPassword,
      ));

      expect(result, const Right(testAuthToken));
      verify(() => mockRepository.login(testEmail, testPassword)).called(1);
    });

    test('should return AuthFailure when login fails', () async {
      when(() => mockRepository.login(testEmail, testPassword))
          .thenAnswer((_) async => const Left(AuthFailure('Invalid credentials')));

      final result = await useCase(LoginParams(
        email: testEmail,
        password: testPassword,
      ));

      expect(result, const Left(AuthFailure('Invalid credentials')));
      verify(() => mockRepository.login(testEmail, testPassword)).called(1);
    });
  });
}
