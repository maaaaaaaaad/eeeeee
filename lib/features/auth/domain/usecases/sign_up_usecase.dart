import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/auth/domain/entities/auth_token.dart';
import 'package:mobile_owner/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase extends UseCase<Either<Failure, AuthToken>, SignUpParams> {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, AuthToken>> call(SignUpParams params) {
    return repository.signUp(
      email: params.email,
      password: params.password,
      businessNumber: params.businessNumber,
      phoneNumber: params.phoneNumber,
      nickname: params.nickname,
    );
  }
}

class SignUpParams {
  final String email;
  final String password;
  final String businessNumber;
  final String phoneNumber;
  final String nickname;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.businessNumber,
    required this.phoneNumber,
    required this.nickname,
  });
}
