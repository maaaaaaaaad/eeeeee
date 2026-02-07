import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/treatment/domain/entities/treatment.dart';
import 'package:mobile_owner/features/treatment/domain/repositories/treatment_repository.dart';

class ListTreatmentsUseCase
    extends UseCase<Either<Failure, List<Treatment>>, String> {
  final TreatmentRepository repository;

  ListTreatmentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Treatment>>> call(String shopId) {
    return repository.listTreatments(shopId);
  }
}
