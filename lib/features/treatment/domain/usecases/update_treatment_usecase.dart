import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/treatment/domain/entities/treatment.dart';
import 'package:mobile_owner/features/treatment/domain/entities/update_treatment_params.dart';
import 'package:mobile_owner/features/treatment/domain/repositories/treatment_repository.dart';

class UpdateTreatmentUseCase
    extends UseCase<Either<Failure, Treatment>, UpdateTreatmentParams> {
  final TreatmentRepository repository;

  UpdateTreatmentUseCase(this.repository);

  @override
  Future<Either<Failure, Treatment>> call(UpdateTreatmentParams params) {
    return repository.updateTreatment(params);
  }
}
