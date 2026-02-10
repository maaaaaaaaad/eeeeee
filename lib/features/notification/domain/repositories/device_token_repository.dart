import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';

abstract class DeviceTokenRepository {
  Future<Either<Failure, void>> registerToken(String token, String platform);
  Future<Either<Failure, void>> unregisterToken(String token);
}
