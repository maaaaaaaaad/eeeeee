import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/category.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/create_shop_params.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/update_shop_params.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';

abstract class BeautishopRepository {
  Future<Either<Failure, BeautyShop>> createShop(CreateShopParams params);
  Future<Either<Failure, BeautyShop>> getShop(String shopId);
  Future<Either<Failure, BeautyShop>> updateShop(UpdateShopParams params);
  Future<Either<Failure, void>> deleteShop(String shopId);
  Future<Either<Failure, List<Category>>> getCategories();
  Future<Either<Failure, void>> setShopCategories(String shopId, List<String> categoryIds);
}
