import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/treatment/domain/repositories/treatment_repository.dart';

class DeleteTreatmentUseCase extends UseCase<Either<Failure, void>, String> {
  final TreatmentRepository repository;

  DeleteTreatmentUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String treatmentId) {
    return repository.deleteTreatment(treatmentId);
  }
}
