import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/designer/domain/entities/designer.dart';
import 'package:mobile_owner/features/designer/domain/entities/designer_id_params.dart';
import 'package:mobile_owner/features/designer/domain/repositories/designer_repository.dart';

class GetDesignerUseCase
    extends UseCase<Either<Failure, Designer>, DesignerIdParams> {
  final DesignerRepository repository;

  GetDesignerUseCase(this.repository);

  @override
  Future<Either<Failure, Designer>> call(DesignerIdParams params) {
    return repository.getDesigner(params.shopId, params.designerId);
  }
}
