import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile_owner/features/designer/data/datasources/designer_remote_datasource.dart';
import 'package:mobile_owner/features/designer/data/repositories/designer_repository_impl.dart';
import 'package:mobile_owner/features/designer/domain/repositories/designer_repository.dart';
import 'package:mobile_owner/features/designer/domain/usecases/create_designer_usecase.dart';
import 'package:mobile_owner/features/designer/domain/usecases/delete_designer_usecase.dart';
import 'package:mobile_owner/features/designer/domain/usecases/get_designer_usecase.dart';
import 'package:mobile_owner/features/designer/domain/usecases/list_designers_usecase.dart';
import 'package:mobile_owner/features/designer/domain/usecases/update_designer_usecase.dart';

final designerRemoteDataSourceProvider =
    Provider<DesignerRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DesignerRemoteDataSourceImpl(apiClient: apiClient);
});

final designerRepositoryProvider = Provider<DesignerRepository>((ref) {
  final remoteDataSource = ref.watch(designerRemoteDataSourceProvider);
  return DesignerRepositoryImpl(remoteDataSource: remoteDataSource);
});

final createDesignerUseCaseProvider = Provider<CreateDesignerUseCase>((ref) {
  return CreateDesignerUseCase(ref.watch(designerRepositoryProvider));
});

final getDesignerUseCaseProvider = Provider<GetDesignerUseCase>((ref) {
  return GetDesignerUseCase(ref.watch(designerRepositoryProvider));
});

final listDesignersUseCaseProvider = Provider<ListDesignersUseCase>((ref) {
  return ListDesignersUseCase(ref.watch(designerRepositoryProvider));
});

final updateDesignerUseCaseProvider = Provider<UpdateDesignerUseCase>((ref) {
  return UpdateDesignerUseCase(ref.watch(designerRepositoryProvider));
});

final deleteDesignerUseCaseProvider = Provider<DeleteDesignerUseCase>((ref) {
  return DeleteDesignerUseCase(ref.watch(designerRepositoryProvider));
});
