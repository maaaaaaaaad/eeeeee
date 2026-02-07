import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/treatment/domain/entities/treatment.dart';
import 'package:mobile_owner/features/treatment/presentation/providers/treatment_provider.dart';

final treatmentListNotifierProvider = AutoDisposeNotifierProviderFamily<
    TreatmentListNotifier, TreatmentListState, String>(
  () => TreatmentListNotifier(),
);

class TreatmentListNotifier
    extends AutoDisposeFamilyNotifier<TreatmentListState, String> {
  @override
  TreatmentListState build(String shopId) {
    return const TreatmentListState();
  }

  Future<void> loadTreatments() async {
    state = state.copyWith(status: TreatmentListStatus.loading);

    final useCase = ref.read(listTreatmentsUseCaseProvider);
    final result = await useCase(arg);

    result.fold(
      (failure) => state = state.copyWith(
        status: TreatmentListStatus.error,
        errorMessage: failure.message,
      ),
      (treatments) => state = state.copyWith(
        status: TreatmentListStatus.loaded,
        treatments: treatments,
      ),
    );
  }

  Future<void> refresh() async {
    await loadTreatments();
  }
}

enum TreatmentListStatus { initial, loading, loaded, error }

class TreatmentListState extends Equatable {
  final TreatmentListStatus status;
  final List<Treatment> treatments;
  final String? errorMessage;

  const TreatmentListState({
    this.status = TreatmentListStatus.initial,
    this.treatments = const [],
    this.errorMessage,
  });

  TreatmentListState copyWith({
    TreatmentListStatus? status,
    List<Treatment>? treatments,
    String? errorMessage,
  }) {
    return TreatmentListState(
      status: status ?? this.status,
      treatments: treatments ?? this.treatments,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, treatments, errorMessage];
}
