import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/designer/domain/entities/create_designer_params.dart';
import 'package:mobile_owner/features/designer/domain/entities/designer.dart';
import 'package:mobile_owner/features/designer/domain/entities/designer_id_params.dart';
import 'package:mobile_owner/features/designer/domain/entities/update_designer_params.dart';
import 'package:mobile_owner/features/designer/presentation/providers/designer_provider.dart';

final designerListNotifierProvider = AutoDisposeNotifierProviderFamily<
    DesignerListNotifier, DesignerListState, String>(
  () => DesignerListNotifier(),
);

class DesignerListNotifier
    extends AutoDisposeFamilyNotifier<DesignerListState, String> {
  @override
  DesignerListState build(String shopId) {
    Future.microtask(loadDesigners);
    return const DesignerListState();
  }

  Future<void> loadDesigners() async {
    state = state.copyWith(status: DesignerListStatus.loading);

    final useCase = ref.read(listDesignersUseCaseProvider);
    final result = await useCase(arg);

    result.fold(
      (failure) => state = state.copyWith(
        status: DesignerListStatus.error,
        errorMessage: failure.message,
      ),
      (designers) => state = state.copyWith(
        status: DesignerListStatus.loaded,
        designers: designers,
        clearError: true,
      ),
    );
  }

  Future<String?> createDesigner(CreateDesignerParams params) async {
    final useCase = ref.read(createDesignerUseCaseProvider);
    final result = await useCase(params);

    return result.fold(
      (failure) => failure.message,
      (designer) {
        state = state.copyWith(
          designers: [...state.designers, designer],
          clearError: true,
        );
        return null;
      },
    );
  }

  Future<String?> updateDesigner(UpdateDesignerParams params) async {
    final useCase = ref.read(updateDesignerUseCaseProvider);
    final result = await useCase(params);

    return result.fold(
      (failure) => failure.message,
      (updated) {
        final next = [
          for (final d in state.designers)
            if (d.id == updated.id) updated else d,
        ];
        state = state.copyWith(designers: next, clearError: true);
        return null;
      },
    );
  }

  Future<String?> deleteDesigner(String designerId) async {
    final useCase = ref.read(deleteDesignerUseCaseProvider);
    final result = await useCase(
      DesignerIdParams(shopId: arg, designerId: designerId),
    );

    return result.fold(
      (failure) => failure.message,
      (_) {
        state = state.copyWith(
          designers:
              state.designers.where((d) => d.id != designerId).toList(),
          clearError: true,
        );
        return null;
      },
    );
  }

  Future<void> refresh() async => loadDesigners();
}

enum DesignerListStatus { initial, loading, loaded, error }

class DesignerListState extends Equatable {
  final DesignerListStatus status;
  final List<Designer> designers;
  final String? errorMessage;

  const DesignerListState({
    this.status = DesignerListStatus.initial,
    this.designers = const [],
    this.errorMessage,
  });

  DesignerListState copyWith({
    DesignerListStatus? status,
    List<Designer>? designers,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DesignerListState(
      status: status ?? this.status,
      designers: designers ?? this.designers,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, designers, errorMessage];
}
