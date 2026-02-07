import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/beautishop_provider.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';

final shopDetailNotifierProvider = AutoDisposeNotifierProviderFamily<
    ShopDetailNotifier, ShopDetailState, String>(() => ShopDetailNotifier());

class ShopDetailNotifier
    extends AutoDisposeFamilyNotifier<ShopDetailState, String> {
  @override
  ShopDetailState build(String shopId) {
    return const ShopDetailState();
  }

  Future<void> loadShop() async {
    await _loadShop(arg);
  }

  Future<void> _loadShop(String shopId) async {
    state = state.copyWith(status: ShopDetailStatus.loading);

    final useCase = ref.read(getBeautishopUseCaseProvider);
    final result = await useCase(shopId);

    result.fold(
      (failure) => state = state.copyWith(
        status: ShopDetailStatus.error,
        errorMessage: failure.message,
      ),
      (shop) => state = state.copyWith(
        status: ShopDetailStatus.loaded,
        shop: shop,
      ),
    );
  }

  Future<void> refresh() async {
    await _loadShop(arg);
  }

  Future<bool> deleteShop() async {
    state = state.copyWith(status: ShopDetailStatus.deleting);

    final useCase = ref.read(deleteBeautishopUseCaseProvider);
    final result = await useCase(arg);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: ShopDetailStatus.loaded,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(status: ShopDetailStatus.deleted);
        return true;
      },
    );
  }
}

enum ShopDetailStatus { initial, loading, loaded, error, deleting, deleted }

class ShopDetailState extends Equatable {
  final ShopDetailStatus status;
  final BeautyShop? shop;
  final String? errorMessage;

  const ShopDetailState({
    this.status = ShopDetailStatus.initial,
    this.shop,
    this.errorMessage,
  });

  ShopDetailState copyWith({
    ShopDetailStatus? status,
    BeautyShop? shop,
    String? errorMessage,
  }) {
    return ShopDetailState(
      status: status ?? this.status,
      shop: shop ?? this.shop,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, shop, errorMessage];
}
