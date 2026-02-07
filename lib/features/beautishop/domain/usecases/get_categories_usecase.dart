import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/category.dart';
import 'package:mobile_owner/features/beautishop/domain/repositories/beautishop_repository.dart';

class GetCategoriesUseCase
    extends UseCase<Either<Failure, List<Category>>, NoParams> {
  final BeautishopRepository repository;

  GetCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Category>>> call(NoParams params) {
    return repository.getCategories();
  }
}
