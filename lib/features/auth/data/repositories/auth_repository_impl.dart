import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/network/api_error_handler.dart';
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
      return Left(ApiErrorHandler.fromDioException(e, fallback: '로그인에 실패했습니다'));
    } catch (_) {
      return const Left(ServerFailure('로그인에 실패했습니다'));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> signUp({
    required String email,
    required String password,
    required String businessNumber,
    required String phoneNumber,
    required String nickname,
    required String emailVerificationToken,
  }) async {
    try {
      final tokenModel = await remoteDataSource.signUp(
        email: email,
        password: password,
        businessNumber: businessNumber,
        phoneNumber: phoneNumber,
        nickname: nickname,
        emailVerificationToken: emailVerificationToken,
      );
      return Right(tokenModel);
    } on DioException catch (e) {
      return Left(ApiErrorHandler.fromDioException(e, fallback: '회원가입에 실패했습니다'));
    } catch (_) {
      return const Left(ServerFailure('회원가입에 실패했습니다'));
    }
  }

  @override
  Future<Either<Failure, void>> sendVerificationCode(String email, {String purpose = 'SIGNUP'}) async {
    try {
      await remoteDataSource.sendVerificationCode(email, purpose: purpose);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ApiErrorHandler.fromDioException(e, fallback: '인증코드 발송에 실패했습니다'));
    } catch (_) {
      return const Left(ServerFailure('인증코드 발송에 실패했습니다'));
    }
  }

  @override
  Future<Either<Failure, String>> verifyCode(String email, String code) async {
    try {
      final token = await remoteDataSource.verifyCode(email, code);
      return Right(token);
    } on DioException catch (e) {
      return Left(ApiErrorHandler.fromDioException(e, fallback: '인증코드 확인에 실패했습니다'));
    } catch (_) {
      return const Left(ServerFailure('인증코드 확인에 실패했습니다'));
    }
  }

  @override
  Future<Either<Failure, void>> sendSmsVerificationCode(String phoneNumber) async {
    try {
      await remoteDataSource.sendSmsVerificationCode(phoneNumber);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ApiErrorHandler.fromDioException(e, fallback: 'SMS 인증코드 발송에 실패했습니다'));
    } catch (_) {
      return const Left(ServerFailure('SMS 인증코드 발송에 실패했습니다'));
    }
  }

  @override
  Future<Either<Failure, String>> verifySmsCode(String phoneNumber, String code) async {
    try {
      final token = await remoteDataSource.verifySmsCode(phoneNumber, code);
      return Right(token);
    } on DioException catch (e) {
      return Left(ApiErrorHandler.fromDioException(e, fallback: 'SMS 인증코드 확인에 실패했습니다'));
    } catch (_) {
      return const Left(ServerFailure('SMS 인증코드 확인에 실패했습니다'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String newPassword,
    required String emailVerificationToken,
  }) async {
    try {
      await remoteDataSource.resetPassword(
        email: email,
        newPassword: newPassword,
        emailVerificationToken: emailVerificationToken,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ApiErrorHandler.fromDioException(e, fallback: '비밀번호 재설정에 실패했습니다'));
    } catch (_) {
      return const Left(ServerFailure('비밀번호 재설정에 실패했습니다'));
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
      return Left(ApiErrorHandler.fromDioException(e, fallback: '인증 갱신에 실패했습니다'));
    } catch (_) {
      return const Left(ServerFailure('인증 갱신에 실패했습니다'));
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
      return Left(ApiErrorHandler.fromDioException(e, fallback: '로그아웃에 실패했습니다'));
    } catch (_) {
      await tokenStorage.clearTokens();
      return const Left(ServerFailure('로그아웃에 실패했습니다'));
    }
  }

  @override
  Future<Either<Failure, Owner>> getCurrentOwner() async {
    try {
      final ownerModel = await remoteDataSource.getCurrentOwner();
      return Right(ownerModel);
    } on DioException catch (e) {
      return Left(ApiErrorHandler.fromDioException(e, fallback: '사용자 정보를 불러올 수 없습니다'));
    } catch (_) {
      return const Left(ServerFailure('사용자 정보를 불러올 수 없습니다'));
    }
  }

  @override
  Future<Either<Failure, void>> withdraw({
    required String password,
    required String reason,
    required String verificationToken,
  }) async {
    try {
      await remoteDataSource.withdraw(
        password: password,
        reason: reason,
        verificationToken: verificationToken,
      );
      await tokenStorage.clearTokens();
      return const Right(null);
    } on DioException catch (e) {
      return Left(ApiErrorHandler.fromDioException(e, fallback: '회원 탈퇴에 실패했습니다'));
    } catch (_) {
      return const Left(ServerFailure('회원 탈퇴에 실패했습니다'));
    }
  }
}
