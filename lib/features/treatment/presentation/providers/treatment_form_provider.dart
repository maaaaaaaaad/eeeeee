import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/treatment/domain/entities/create_treatment_params.dart';
import 'package:mobile_owner/features/treatment/domain/entities/update_treatment_params.dart';
import 'package:mobile_owner/features/treatment/presentation/providers/treatment_provider.dart';

final treatmentFormNotifierProvider =
    AutoDisposeNotifierProvider<TreatmentFormNotifier, TreatmentFormState>(
  () => TreatmentFormNotifier(),
);

class TreatmentFormNotifier extends AutoDisposeNotifier<TreatmentFormState> {
  @override
  TreatmentFormState build() {
    return const TreatmentFormState();
  }

  Future<void> create(CreateTreatmentParams params) async {
    state = state.copyWith(status: TreatmentFormStatus.loading);

    final useCase = ref.read(createTreatmentUseCaseProvider);
    final result = await useCase(params);

    result.fold(
      (failure) => state = state.copyWith(
        status: TreatmentFormStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(status: TreatmentFormStatus.success),
    );
  }

  Future<void> update(UpdateTreatmentParams params) async {
    state = state.copyWith(status: TreatmentFormStatus.loading);

    final useCase = ref.read(updateTreatmentUseCaseProvider);
    final result = await useCase(params);

    result.fold(
      (failure) => state = state.copyWith(
        status: TreatmentFormStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(status: TreatmentFormStatus.success),
    );
  }

  Future<bool> delete(String treatmentId) async {
    state = state.copyWith(status: TreatmentFormStatus.loading);

    final useCase = ref.read(deleteTreatmentUseCaseProvider);
    final result = await useCase(treatmentId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: TreatmentFormStatus.initial,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(status: TreatmentFormStatus.deleted);
        return true;
      },
    );
  }
}

enum TreatmentFormStatus { initial, loading, success, error, deleted }

class TreatmentFormState extends Equatable {
  final TreatmentFormStatus status;
  final String? errorMessage;

  const TreatmentFormState({
    this.status = TreatmentFormStatus.initial,
    this.errorMessage,
  });

  TreatmentFormState copyWith({
    TreatmentFormStatus? status,
    String? errorMessage,
  }) {
    return TreatmentFormState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
