import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/network/api_error_handler.dart';
import 'package:mobile_owner/features/designer/data/datasources/designer_remote_datasource.dart';
import 'package:mobile_owner/features/designer/data/models/create_designer_request.dart';
import 'package:mobile_owner/features/designer/data/models/update_designer_request.dart';
import 'package:mobile_owner/features/designer/domain/entities/create_designer_params.dart';
import 'package:mobile_owner/features/designer/domain/entities/designer.dart';
import 'package:mobile_owner/features/designer/domain/entities/update_designer_params.dart';
import 'package:mobile_owner/features/designer/domain/repositories/designer_repository.dart';

class DesignerRepositoryImpl implements DesignerRepository {
  final DesignerRemoteDataSource _remoteDataSource;

  DesignerRepositoryImpl({required DesignerRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, Designer>> createDesigner(
      CreateDesignerParams params) async {
    try {
      final request = CreateDesignerRequest(
        name: params.name,
        nickname: params.nickname,
        intro: params.intro,
        photoUrls: params.photoUrls,
      );
      final designer =
          await _remoteDataSource.createDesigner(params.shopId, request);
      return Right(designer);
    } on DioException catch (e) {
      return Left(
          ApiErrorHandler.fromDioException(e, fallback: '디자이너 등록에 실패했습니다'));
    } catch (_) {
      return const Left(ServerFailure('디자이너 등록에 실패했습니다'));
    }
  }

  @override
  Future<Either<Failure, Designer>> getDesigner(
      String shopId, String designerId) async {
    try {
      final designer = await _remoteDataSource.getDesigner(shopId, designerId);
      return Right(designer);
    } on DioException catch (e) {
      return Left(ApiErrorHandler.fromDioException(e,
          fallback: '디자이너 정보를 불러올 수 없습니다'));
    } catch (_) {
      return const Left(ServerFailure('디자이너 정보를 불러올 수 없습니다'));
    }
  }

  @override
  Future<Either<Failure, List<Designer>>> listDesigners(String shopId) async {
    try {
      final designers = await _remoteDataSource.listDesigners(shopId);
      return Right(designers);
    } on DioException catch (e) {
      return Left(ApiErrorHandler.fromDioException(e,
          fallback: '디자이너 목록을 불러올 수 없습니다'));
    } catch (_) {
      return const Left(ServerFailure('디자이너 목록을 불러올 수 없습니다'));
    }
  }

  @override
  Future<Either<Failure, Designer>> updateDesigner(
      UpdateDesignerParams params) async {
    try {
      final request = UpdateDesignerRequest(
        name: params.name,
        nickname: params.nickname,
        intro: params.intro,
        photoUrls: params.photoUrls,
      );
      final designer = await _remoteDataSource.updateDesigner(
          params.shopId, params.designerId, request);
      return Right(designer);
    } on DioException catch (e) {
      return Left(
          ApiErrorHandler.fromDioException(e, fallback: '디자이너 수정에 실패했습니다'));
    } catch (_) {
      return const Left(ServerFailure('디자이너 수정에 실패했습니다'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDesigner(
      String shopId, String designerId) async {
    try {
      await _remoteDataSource.deleteDesigner(shopId, designerId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
          ApiErrorHandler.fromDioException(e, fallback: '디자이너 삭제에 실패했습니다'));
    } catch (_) {
      return const Left(ServerFailure('디자이너 삭제에 실패했습니다'));
    }
  }
}
