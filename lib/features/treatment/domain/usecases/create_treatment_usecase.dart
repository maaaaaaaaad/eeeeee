import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/treatment/domain/entities/create_treatment_params.dart';
import 'package:mobile_owner/features/treatment/domain/entities/treatment.dart';
import 'package:mobile_owner/features/treatment/domain/repositories/treatment_repository.dart';

class CreateTreatmentUseCase
    extends UseCase<Either<Failure, Treatment>, CreateTreatmentParams> {
  final TreatmentRepository repository;

  CreateTreatmentUseCase(this.repository);

  @override
  Future<Either<Failure, Treatment>> call(CreateTreatmentParams params) {
    return repository.createTreatment(params);
  }
}
