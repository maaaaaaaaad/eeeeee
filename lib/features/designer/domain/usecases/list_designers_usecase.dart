import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/designer/domain/entities/designer.dart';
import 'package:mobile_owner/features/designer/domain/repositories/designer_repository.dart';

class ListDesignersUseCase
    extends UseCase<Either<Failure, List<Designer>>, String> {
  final DesignerRepository repository;

  ListDesignersUseCase(this.repository);

  @override
  Future<Either<Failure, List<Designer>>> call(String shopId) {
    return repository.listDesigners(shopId);
  }
}
