import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile_owner/features/treatment/data/datasources/treatment_remote_datasource.dart';
import 'package:mobile_owner/features/treatment/data/repositories/treatment_repository_impl.dart';
import 'package:mobile_owner/features/treatment/domain/repositories/treatment_repository.dart';
import 'package:mobile_owner/features/treatment/domain/usecases/create_treatment_usecase.dart';
import 'package:mobile_owner/features/treatment/domain/usecases/delete_treatment_usecase.dart';
import 'package:mobile_owner/features/treatment/domain/usecases/get_treatment_usecase.dart';
import 'package:mobile_owner/features/treatment/domain/usecases/list_treatments_usecase.dart';
import 'package:mobile_owner/features/treatment/domain/usecases/update_treatment_usecase.dart';

final treatmentRemoteDataSourceProvider =
    Provider<TreatmentRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TreatmentRemoteDataSourceImpl(apiClient: apiClient);
});

final treatmentRepositoryProvider = Provider<TreatmentRepository>((ref) {
  final remoteDataSource = ref.watch(treatmentRemoteDataSourceProvider);
  return TreatmentRepositoryImpl(remoteDataSource: remoteDataSource);
});

final createTreatmentUseCaseProvider =
    Provider<CreateTreatmentUseCase>((ref) {
  return CreateTreatmentUseCase(ref.watch(treatmentRepositoryProvider));
});

final getTreatmentUseCaseProvider = Provider<GetTreatmentUseCase>((ref) {
  return GetTreatmentUseCase(ref.watch(treatmentRepositoryProvider));
});

final listTreatmentsUseCaseProvider =
    Provider<ListTreatmentsUseCase>((ref) {
  return ListTreatmentsUseCase(ref.watch(treatmentRepositoryProvider));
});

final updateTreatmentUseCaseProvider =
    Provider<UpdateTreatmentUseCase>((ref) {
  return UpdateTreatmentUseCase(ref.watch(treatmentRepositoryProvider));
});

final deleteTreatmentUseCaseProvider =
    Provider<DeleteTreatmentUseCase>((ref) {
  return DeleteTreatmentUseCase(ref.watch(treatmentRepositoryProvider));
});
