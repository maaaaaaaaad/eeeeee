import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/treatment/domain/entities/treatment.dart';
import 'package:mobile_owner/features/treatment/domain/repositories/treatment_repository.dart';

class GetTreatmentUseCase extends UseCase<Either<Failure, Treatment>, String> {
  final TreatmentRepository repository;

  GetTreatmentUseCase(this.repository);

  @override
  Future<Either<Failure, Treatment>> call(String treatmentId) {
    return repository.getTreatment(treatmentId);
  }
}
