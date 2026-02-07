import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/update_shop_params.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/beautishop_provider.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';

final shopEditNotifierProvider =
    AutoDisposeNotifierProvider<ShopEditNotifier, ShopEditState>(
        () => ShopEditNotifier());

class ShopEditNotifier extends AutoDisposeNotifier<ShopEditState> {
  @override
  ShopEditState build() {
    return const ShopEditState();
  }

  Future<void> update(UpdateShopParams params) async {
    state = state.copyWith(status: ShopEditStatus.loading);

    final useCase = ref.read(updateBeautishopUseCaseProvider);
    final result = await useCase(params);

    result.fold(
      (failure) => state = state.copyWith(
        status: ShopEditStatus.error,
        errorMessage: failure.message,
      ),
      (shop) => state = state.copyWith(
        status: ShopEditStatus.success,
        updatedShop: shop,
      ),
    );
  }
}

enum ShopEditStatus { initial, loading, success, error }

class ShopEditState extends Equatable {
  final ShopEditStatus status;
  final BeautyShop? updatedShop;
  final String? errorMessage;

  const ShopEditState({
    this.status = ShopEditStatus.initial,
    this.updatedShop,
    this.errorMessage,
  });

  ShopEditState copyWith({
    ShopEditStatus? status,
    BeautyShop? updatedShop,
    String? errorMessage,
  }) {
    return ShopEditState(
      status: status ?? this.status,
      updatedShop: updatedShop ?? this.updatedShop,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, updatedShop, errorMessage];
}
