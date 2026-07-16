import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/designer/domain/entities/create_designer_params.dart';
import 'package:mobile_owner/features/designer/domain/entities/designer.dart';
import 'package:mobile_owner/features/designer/domain/repositories/designer_repository.dart';

class CreateDesignerUseCase
    extends UseCase<Either<Failure, Designer>, CreateDesignerParams> {
  final DesignerRepository repository;

  CreateDesignerUseCase(this.repository);

  @override
  Future<Either<Failure, Designer>> call(CreateDesignerParams params) {
    return repository.createDesigner(params);
  }
}
