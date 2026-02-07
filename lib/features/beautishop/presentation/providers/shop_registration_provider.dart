import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/create_shop_params.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/beautishop_provider.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';

final shopRegistrationNotifierProvider =
    AutoDisposeNotifierProvider<ShopRegistrationNotifier, ShopRegistrationState>(
        () => ShopRegistrationNotifier());

class ShopRegistrationNotifier
    extends AutoDisposeNotifier<ShopRegistrationState> {
  @override
  ShopRegistrationState build() {
    return const ShopRegistrationState();
  }

  Future<void> register(CreateShopParams params) async {
    state = state.copyWith(status: ShopRegistrationStatus.loading);

    final useCase = ref.read(createBeautishopUseCaseProvider);
    final result = await useCase(params);

    result.fold(
      (failure) => state = state.copyWith(
        status: ShopRegistrationStatus.error,
        errorMessage: failure.message,
      ),
      (shop) => state = state.copyWith(
        status: ShopRegistrationStatus.success,
        createdShop: shop,
      ),
    );
  }
}

enum ShopRegistrationStatus { initial, loading, success, error }

class ShopRegistrationState extends Equatable {
  final ShopRegistrationStatus status;
  final BeautyShop? createdShop;
  final String? errorMessage;

  const ShopRegistrationState({
    this.status = ShopRegistrationStatus.initial,
    this.createdShop,
    this.errorMessage,
  });

  ShopRegistrationState copyWith({
    ShopRegistrationStatus? status,
    BeautyShop? createdShop,
    String? errorMessage,
  }) {
    return ShopRegistrationState(
      status: status ?? this.status,
      createdShop: createdShop ?? this.createdShop,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, createdShop, errorMessage];
}
