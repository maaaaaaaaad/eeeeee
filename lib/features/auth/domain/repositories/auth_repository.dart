import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/auth/domain/entities/auth_token.dart';
import 'package:mobile_owner/features/auth/domain/entities/owner.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthToken>> login(String email, String password);
  Future<Either<Failure, AuthToken>> signUp({
    required String email,
    required String password,
    required String businessNumber,
    required String phoneNumber,
    required String nickname,
    required String emailVerificationToken,
  });
  Future<Either<Failure, void>> sendVerificationCode(String email);
  Future<Either<Failure, String>> verifyCode(String email, String code);
  Future<Either<Failure, AuthToken>> refreshToken(String refreshToken);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, Owner>> getCurrentOwner();
}
