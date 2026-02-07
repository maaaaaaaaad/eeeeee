import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/beautishop/data/datasources/beautishop_remote_datasource.dart';
import 'package:mobile_owner/features/beautishop/data/models/create_beautishop_request.dart';
import 'package:mobile_owner/features/beautishop/data/models/update_beautishop_request.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/category.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/create_shop_params.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/update_shop_params.dart';
import 'package:mobile_owner/features/beautishop/domain/repositories/beautishop_repository.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';

class BeautishopRepositoryImpl implements BeautishopRepository {
  final BeautishopRemoteDataSource _remoteDataSource;

  BeautishopRepositoryImpl({required BeautishopRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, BeautyShop>> createShop(CreateShopParams params) async {
    try {
      final request = CreateBeautishopRequest(
        name: params.name,
        regNum: params.regNum,
        phoneNumber: params.phoneNumber,
        address: params.address,
        latitude: params.latitude,
        longitude: params.longitude,
        operatingTime: params.operatingTime,
        shopDescription: params.shopDescription,
        shopImages: params.shopImages,
      );
      final shop = await _remoteDataSource.createShop(request);
      return Right(shop);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return const Left(ValidationFailure('입력 정보를 확인해주세요'));
      }
      return Left(ServerFailure(
        e.response?.data?['message']?.toString() ?? '샵 등록에 실패했습니다',
      ));
    }
  }

  @override
  Future<Either<Failure, BeautyShop>> getShop(String shopId) async {
    try {
      final shop = await _remoteDataSource.getShop(shopId);
      return Right(shop);
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.response?.data?['message']?.toString() ?? '샵 정보를 불러올 수 없습니다',
      ));
    }
  }

  @override
  Future<Either<Failure, BeautyShop>> updateShop(UpdateShopParams params) async {
    try {
      final request = UpdateBeautishopRequest(
        operatingTime: params.operatingTime,
        shopDescription: params.shopDescription,
        shopImages: params.shopImages,
      );
      final shop = await _remoteDataSource.updateShop(params.shopId, request);
      return Right(shop);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return const Left(ValidationFailure('입력 정보를 확인해주세요'));
      }
      return Left(ServerFailure(
        e.response?.data?['message']?.toString() ?? '샵 수정에 실패했습니다',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteShop(String shopId) async {
    try {
      await _remoteDataSource.deleteShop(shopId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.response?.data?['message']?.toString() ?? '샵 삭제에 실패했습니다',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final categories = await _remoteDataSource.getCategories();
      return Right(categories);
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.response?.data?['message']?.toString() ?? '카테고리를 불러올 수 없습니다',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> setShopCategories(
    String shopId,
    List<String> categoryIds,
  ) async {
    try {
      await _remoteDataSource.setShopCategories(shopId, categoryIds);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.response?.data?['message']?.toString() ?? '카테고리 설정에 실패했습니다',
      ));
    }
  }
}
