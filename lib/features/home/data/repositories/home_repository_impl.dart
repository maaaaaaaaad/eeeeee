import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/auth/domain/entities/owner.dart';
import 'package:mobile_owner/features/home/data/datasources/home_remote_datasource.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';
import 'package:mobile_owner/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepositoryImpl({required HomeRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, Owner>> getMyProfile() async {
    try {
      final owner = await _remoteDataSource.getMyProfile();
      return Right(owner);
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.response?.data?['message']?.toString() ?? '프로필을 불러올 수 없습니다',
      ));
    } catch (_) {
      return Left(const ServerFailure('프로필을 불러올 수 없습니다'));
    }
  }

  @override
  Future<Either<Failure, List<BeautyShop>>> getMyShops() async {
    try {
      final shops = await _remoteDataSource.getMyShops();
      return Right(shops);
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.response?.data?['message']?.toString() ?? '샵 목록을 불러올 수 없습니다',
      ));
    } catch (_) {
      return Left(const ServerFailure('샵 목록을 불러올 수 없습니다'));
    }
  }
}
