import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/auth/domain/entities/owner.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';

abstract class HomeRepository {
  Future<Either<Failure, Owner>> getMyProfile();
  Future<Either<Failure, List<BeautyShop>>> getMyShops();
}
