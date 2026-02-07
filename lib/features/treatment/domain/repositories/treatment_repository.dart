import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/treatment/domain/entities/create_treatment_params.dart';
import 'package:mobile_owner/features/treatment/domain/entities/treatment.dart';
import 'package:mobile_owner/features/treatment/domain/entities/update_treatment_params.dart';

abstract class TreatmentRepository {
  Future<Either<Failure, Treatment>> createTreatment(
      CreateTreatmentParams params);
  Future<Either<Failure, Treatment>> getTreatment(String treatmentId);
  Future<Either<Failure, List<Treatment>>> listTreatments(String shopId);
  Future<Either<Failure, Treatment>> updateTreatment(
      UpdateTreatmentParams params);
  Future<Either<Failure, void>> deleteTreatment(String treatmentId);
}
