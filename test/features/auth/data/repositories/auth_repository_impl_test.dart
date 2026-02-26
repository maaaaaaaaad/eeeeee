import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/storage/secure_token_storage.dart';
import 'package:mobile_owner/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mobile_owner/features/auth/data/models/auth_token_model.dart';
import 'package:mobile_owner/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockSecureTokenStorage extends Mock implements SecureTokenStorage {}

void main() {
  late MockAuthRemoteDataSource mockDataSource;
  late MockSecureTokenStorage mockTokenStorage;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    mockTokenStorage = MockSecureTokenStorage();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockDataSource,
      tokenStorage: mockTokenStorage,
    );
  });

  const testTokenModel = AuthTokenModel(
    accessToken: 'test_access_token',
    refreshToken: 'test_refresh_token',
  );

  group('signUp', () {
    test('should NOT save tokens after successful sign up', () async {
      when(() => mockDataSource.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            businessNumber: any(named: 'businessNumber'),
            phoneNumber: any(named: 'phoneNumber'),
            nickname: any(named: 'nickname'),
          )).thenAnswer((_) async => testTokenModel);

      await repository.signUp(
        email: 'test@test.com',
        password: 'password123',
        businessNumber: '1234567890',
        phoneNumber: '01012345678',
        nickname: 'tester',
      );

      verifyNever(() => mockTokenStorage.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          ));
    });

    test('should return Right(AuthToken) on success', () async {
      when(() => mockDataSource.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            businessNumber: any(named: 'businessNumber'),
            phoneNumber: any(named: 'phoneNumber'),
            nickname: any(named: 'nickname'),
          )).thenAnswer((_) async => testTokenModel);

      final result = await repository.signUp(
        email: 'test@test.com',
        password: 'password123',
        businessNumber: '1234567890',
        phoneNumber: '01012345678',
        nickname: 'tester',
      );

      expect(result, const Right(testTokenModel));
    });

    test('should return ValidationFailure on 409 conflict', () async {
      when(() => mockDataSource.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            businessNumber: any(named: 'businessNumber'),
            phoneNumber: any(named: 'phoneNumber'),
            nickname: any(named: 'nickname'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 409,
        ),
      ));

      final result = await repository.signUp(
        email: 'test@test.com',
        password: 'password123',
        businessNumber: '1234567890',
        phoneNumber: '01012345678',
        nickname: 'tester',
      );

      expect(result, const Left(ValidationFailure('이미 등록된 정보입니다')));
    });
  });

  group('login', () {
    test('should save tokens after successful login', () async {
      when(() => mockDataSource.login(any(), any()))
          .thenAnswer((_) async => testTokenModel);
      when(() => mockTokenStorage.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          )).thenAnswer((_) async {});

      await repository.login('test@test.com', 'password123');

      verify(() => mockTokenStorage.saveTokens(
            accessToken: testTokenModel.accessToken,
            refreshToken: testTokenModel.refreshToken,
          )).called(1);
    });
  });
}
