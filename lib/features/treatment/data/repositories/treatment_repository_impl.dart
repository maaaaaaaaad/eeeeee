import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/treatment/data/datasources/treatment_remote_datasource.dart';
import 'package:mobile_owner/features/treatment/data/models/create_treatment_request.dart';
import 'package:mobile_owner/features/treatment/data/models/update_treatment_request.dart';
import 'package:mobile_owner/features/treatment/domain/entities/create_treatment_params.dart';
import 'package:mobile_owner/features/treatment/domain/entities/treatment.dart';
import 'package:mobile_owner/features/treatment/domain/entities/update_treatment_params.dart';
import 'package:mobile_owner/features/treatment/domain/repositories/treatment_repository.dart';

class TreatmentRepositoryImpl implements TreatmentRepository {
  final TreatmentRemoteDataSource _remoteDataSource;

  TreatmentRepositoryImpl({required TreatmentRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, Treatment>> createTreatment(
      CreateTreatmentParams params) async {
    try {
      final request = CreateTreatmentRequest(
        name: params.name,
        price: params.price,
        duration: params.duration,
        description: params.description,
      );
      final treatment =
          await _remoteDataSource.createTreatment(params.shopId, request);
      return Right(treatment);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return const Left(ValidationFailure('입력 정보를 확인해주세요'));
      }
      return Left(ServerFailure(
        e.response?.data?['message']?.toString() ?? '시술 등록에 실패했습니다',
      ));
    } catch (_) {
      return const Left(ServerFailure('시술 등록에 실패했습니다'));
    }
  }

  @override
  Future<Either<Failure, Treatment>> getTreatment(String treatmentId) async {
    try {
      final treatment = await _remoteDataSource.getTreatment(treatmentId);
      return Right(treatment);
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.response?.data?['message']?.toString() ?? '시술 정보를 불러올 수 없습니다',
      ));
    } catch (_) {
      return const Left(ServerFailure('시술 정보를 불러올 수 없습니다'));
    }
  }

  @override
  Future<Either<Failure, List<Treatment>>> listTreatments(
      String shopId) async {
    try {
      final treatments = await _remoteDataSource.listTreatments(shopId);
      return Right(treatments);
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.response?.data?['message']?.toString() ?? '시술 목록을 불러올 수 없습니다',
      ));
    } catch (_) {
      return const Left(ServerFailure('시술 목록을 불러올 수 없습니다'));
    }
  }

  @override
  Future<Either<Failure, Treatment>> updateTreatment(
      UpdateTreatmentParams params) async {
    try {
      final request = UpdateTreatmentRequest(
        name: params.name,
        price: params.price,
        duration: params.duration,
        description: params.description,
      );
      final treatment = await _remoteDataSource.updateTreatment(
          params.treatmentId, request);
      return Right(treatment);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return const Left(ValidationFailure('입력 정보를 확인해주세요'));
      }
      return Left(ServerFailure(
        e.response?.data?['message']?.toString() ?? '시술 수정에 실패했습니다',
      ));
    } catch (_) {
      return const Left(ServerFailure('시술 수정에 실패했습니다'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTreatment(String treatmentId) async {
    try {
      await _remoteDataSource.deleteTreatment(treatmentId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.response?.data?['message']?.toString() ?? '시술 삭제에 실패했습니다',
      ));
    } catch (_) {
      return const Left(ServerFailure('시술 삭제에 실패했습니다'));
    }
  }
}
