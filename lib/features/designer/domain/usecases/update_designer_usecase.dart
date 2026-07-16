import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/designer/domain/entities/designer.dart';
import 'package:mobile_owner/features/designer/domain/entities/update_designer_params.dart';
import 'package:mobile_owner/features/designer/domain/repositories/designer_repository.dart';

class UpdateDesignerUseCase
    extends UseCase<Either<Failure, Designer>, UpdateDesignerParams> {
  final DesignerRepository repository;

  UpdateDesignerUseCase(this.repository);

  @override
  Future<Either<Failure, Designer>> call(UpdateDesignerParams params) {
    return repository.updateDesigner(params);
  }
}
