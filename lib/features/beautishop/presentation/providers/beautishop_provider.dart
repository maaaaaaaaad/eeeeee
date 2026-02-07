import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile_owner/features/beautishop/data/datasources/beautishop_remote_datasource.dart';
import 'package:mobile_owner/features/beautishop/data/repositories/beautishop_repository_impl.dart';
import 'package:mobile_owner/features/beautishop/domain/repositories/beautishop_repository.dart';
import 'package:mobile_owner/features/beautishop/domain/usecases/create_beautishop_usecase.dart';
import 'package:mobile_owner/features/beautishop/domain/usecases/delete_beautishop_usecase.dart';
import 'package:mobile_owner/features/beautishop/domain/usecases/get_beautishop_usecase.dart';
import 'package:mobile_owner/features/beautishop/domain/usecases/get_categories_usecase.dart';
import 'package:mobile_owner/features/beautishop/domain/usecases/set_shop_categories_usecase.dart';
import 'package:mobile_owner/features/beautishop/domain/usecases/update_beautishop_usecase.dart';

final beautishopRemoteDataSourceProvider =
    Provider<BeautishopRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BeautishopRemoteDataSourceImpl(apiClient: apiClient);
});

final beautishopRepositoryProvider = Provider<BeautishopRepository>((ref) {
  final remoteDataSource = ref.watch(beautishopRemoteDataSourceProvider);
  return BeautishopRepositoryImpl(remoteDataSource: remoteDataSource);
});

final createBeautishopUseCaseProvider =
    Provider<CreateBeautishopUseCase>((ref) {
  return CreateBeautishopUseCase(ref.watch(beautishopRepositoryProvider));
});

final getBeautishopUseCaseProvider = Provider<GetBeautishopUseCase>((ref) {
  return GetBeautishopUseCase(ref.watch(beautishopRepositoryProvider));
});

final updateBeautishopUseCaseProvider =
    Provider<UpdateBeautishopUseCase>((ref) {
  return UpdateBeautishopUseCase(ref.watch(beautishopRepositoryProvider));
});

final deleteBeautishopUseCaseProvider =
    Provider<DeleteBeautishopUseCase>((ref) {
  return DeleteBeautishopUseCase(ref.watch(beautishopRepositoryProvider));
});

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  return GetCategoriesUseCase(ref.watch(beautishopRepositoryProvider));
});

final setShopCategoriesUseCaseProvider =
    Provider<SetShopCategoriesUseCase>((ref) {
  return SetShopCategoriesUseCase(ref.watch(beautishopRepositoryProvider));
});
