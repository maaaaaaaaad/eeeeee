import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/auth/domain/entities/owner.dart';
import 'package:mobile_owner/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile_owner/features/home/data/datasources/home_remote_datasource.dart';
import 'package:mobile_owner/features/home/data/repositories/home_repository_impl.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';
import 'package:mobile_owner/features/home/domain/repositories/home_repository.dart';
import 'package:mobile_owner/features/home/domain/usecases/get_my_profile_usecase.dart';
import 'package:mobile_owner/features/home/domain/usecases/get_my_shops_usecase.dart';

final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HomeRemoteDataSourceImpl(apiClient: apiClient);
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final remoteDataSource = ref.watch(homeRemoteDataSourceProvider);
  return HomeRepositoryImpl(remoteDataSource: remoteDataSource);
});

final getMyProfileUseCaseProvider = Provider<GetMyProfileUseCase>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return GetMyProfileUseCase(repository);
});

final getMyShopsUseCaseProvider = Provider<GetMyShopsUseCase>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return GetMyShopsUseCase(repository);
});

final homeNotifierProvider =
    AutoDisposeNotifierProvider<HomeNotifier, HomeState>(() {
  return HomeNotifier();
});

class HomeNotifier extends AutoDisposeNotifier<HomeState> {
  @override
  HomeState build() {
    loadData();
    return const HomeState();
  }

  Future<void> loadData() async {
    state = state.copyWith(status: HomeStatus.loading);

    final profileUseCase = ref.read(getMyProfileUseCaseProvider);
    final shopsUseCase = ref.read(getMyShopsUseCaseProvider);

    final results = await Future.wait([
      profileUseCase(NoParams()),
      shopsUseCase(NoParams()),
    ]);

    final profileResult = results[0];
    final shopsResult = results[1];

    String? errorMessage;

    Owner? owner;
    profileResult.fold(
      (failure) => errorMessage = failure.message,
      (data) => owner = data as Owner,
    );

    List<BeautyShop> shops = [];
    shopsResult.fold(
      (failure) => errorMessage ??= failure.message,
      (data) => shops = data as List<BeautyShop>,
    );

    if (errorMessage != null) {
      state = state.copyWith(
        status: HomeStatus.error,
        errorMessage: errorMessage,
      );
      return;
    }

    state = state.copyWith(
      status: HomeStatus.loaded,
      owner: owner,
      shops: shops,
    );
  }

  Future<void> refresh() async {
    await loadData();
  }
}

enum HomeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final Owner? owner;
  final List<BeautyShop> shops;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.owner,
    this.shops = const [],
    this.errorMessage,
  });

  bool get hasShops => shops.isNotEmpty;

  HomeState copyWith({
    HomeStatus? status,
    Owner? owner,
    List<BeautyShop>? shops,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      owner: owner ?? this.owner,
      shops: shops ?? this.shops,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, owner, shops, errorMessage];
}
