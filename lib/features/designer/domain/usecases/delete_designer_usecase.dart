import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/designer/domain/entities/designer_id_params.dart';
import 'package:mobile_owner/features/designer/domain/repositories/designer_repository.dart';

class DeleteDesignerUseCase
    extends UseCase<Either<Failure, void>, DesignerIdParams> {
  final DesignerRepository repository;

  DeleteDesignerUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DesignerIdParams params) {
    return repository.deleteDesigner(params.shopId, params.designerId);
  }
}
