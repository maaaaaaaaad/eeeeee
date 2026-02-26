import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/storage/secure_token_storage.dart';
import 'package:mobile_owner/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mobile_owner/features/auth/domain/entities/auth_token.dart';
import 'package:mobile_owner/features/auth/domain/entities/owner.dart';
import 'package:mobile_owner/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureTokenStorage tokenStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<Either<Failure, AuthToken>> login(String email, String password) async {
    try {
      final tokenModel = await remoteDataSource.login(email, password);
      await tokenStorage.saveTokens(
        accessToken: tokenModel.accessToken,
        refreshToken: tokenModel.refreshToken,
      );
      return Right(tokenModel);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return const Left(AuthFailure('이메일 또는 비밀번호가 올바르지 않습니다'));
      }
      return Left(ServerFailure(e.message ?? '서버 오류가 발생했습니다'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> signUp({
    required String email,
    required String password,
    required String businessNumber,
    required String phoneNumber,
    required String nickname,
  }) async {
    try {
      final tokenModel = await remoteDataSource.signUp(
        email: email,
        password: password,
        businessNumber: businessNumber,
        phoneNumber: phoneNumber,
        nickname: nickname,
      );
      return Right(tokenModel);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return const Left(ValidationFailure('이미 등록된 정보입니다'));
      }
      if (e.response?.statusCode == 422) {
        return const Left(ValidationFailure('입력 정보를 확인해주세요'));
      }
      if (e.response?.statusCode == 400) {
        return const Left(ValidationFailure('입력 정보를 확인해주세요'));
      }
      return Left(ServerFailure(e.message ?? '서버 오류가 발생했습니다'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> refreshToken(String refreshToken) async {
    try {
      final tokenModel = await remoteDataSource.refreshToken(refreshToken);
      await tokenStorage.saveTokens(
        accessToken: tokenModel.accessToken,
        refreshToken: tokenModel.refreshToken,
      );
      return Right(tokenModel);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await tokenStorage.clearTokens();
        return const Left(AuthFailure('세션이 만료되었습니다. 다시 로그인해주세요'));
      }
      return Left(ServerFailure(e.message ?? '서버 오류가 발생했습니다'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await tokenStorage.clearTokens();
      return const Right(null);
    } on DioException catch (e) {
      await tokenStorage.clearTokens();
      return Left(ServerFailure(e.message ?? '서버 오류가 발생했습니다'));
    } catch (e) {
      await tokenStorage.clearTokens();
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Owner>> getCurrentOwner() async {
    try {
      final ownerModel = await remoteDataSource.getCurrentOwner();
      return Right(ownerModel);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return const Left(AuthFailure('인증이 필요합니다'));
      }
      return Left(ServerFailure(e.message ?? '서버 오류가 발생했습니다'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
