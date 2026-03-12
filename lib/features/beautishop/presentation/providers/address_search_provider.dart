import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/beautishop/data/datasources/geocode_remote_datasource.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/geocode_result.dart';

final geocodeRemoteDataSourceProvider = Provider<GeocodeRemoteDataSource>(
  (ref) => GeocodeRemoteDataSourceImpl(),
);

final addressSearchNotifierProvider =
    AutoDisposeNotifierProvider<AddressSearchNotifier, AddressSearchState>(
        () => AddressSearchNotifier());

class AddressSearchNotifier extends AutoDisposeNotifier<AddressSearchState> {
  Timer? _debounceTimer;

  @override
  AddressSearchState build() {
    ref.onDispose(() => _debounceTimer?.cancel());
    return const AddressSearchState();
  }

  void search(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      state = const AddressSearchState();
      return;
    }

    state = state.copyWith(status: AddressSearchStatus.loading);

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query.trim());
    });
  }

  Future<void> searchImmediate(String query) async {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      state = const AddressSearchState();
      return;
    }

    state = state.copyWith(status: AddressSearchStatus.loading);
    await _performSearch(query.trim());
  }

  Future<void> _performSearch(String query) async {
    try {
      final dataSource = ref.read(geocodeRemoteDataSourceProvider);
      final results = await dataSource.searchAddress(query);

      state = state.copyWith(
        status: AddressSearchStatus.success,
        results: results,
      );
    } catch (_) {
      state = state.copyWith(
        status: AddressSearchStatus.error,
        errorMessage: '주소 검색에 실패했습니다',
      );
    }
  }

  void clear() {
    _debounceTimer?.cancel();
    state = const AddressSearchState();
  }
}

enum AddressSearchStatus { initial, loading, success, error }

class AddressSearchState extends Equatable {
  final AddressSearchStatus status;
  final List<GeocodeResult> results;
  final String? errorMessage;

  const AddressSearchState({
    this.status = AddressSearchStatus.initial,
    this.results = const [],
    this.errorMessage,
  });

  AddressSearchState copyWith({
    AddressSearchStatus? status,
    List<GeocodeResult>? results,
    String? errorMessage,
  }) {
    return AddressSearchState(
      status: status ?? this.status,
      results: results ?? this.results,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, results, errorMessage];
}
