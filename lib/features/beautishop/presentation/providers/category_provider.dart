import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/category.dart';
import 'package:mobile_owner/features/beautishop/domain/usecases/set_shop_categories_usecase.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/beautishop_provider.dart';

final categoryNotifierProvider =
    AutoDisposeNotifierProvider<CategoryNotifier, CategoryState>(
        () => CategoryNotifier());

class CategoryNotifier extends AutoDisposeNotifier<CategoryState> {
  @override
  CategoryState build() {
    return const CategoryState();
  }

  Future<void> loadCategories() async {
    state = state.copyWith(status: CategoryStatus.loading);

    final useCase = ref.read(getCategoriesUseCaseProvider);
    final result = await useCase(NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        status: CategoryStatus.error,
        errorMessage: failure.message,
      ),
      (categories) => state = state.copyWith(
        status: CategoryStatus.loaded,
        allCategories: categories,
      ),
    );
  }

  void toggleCategory(String categoryId) {
    final selected = Set<String>.from(state.selectedCategoryIds);
    if (selected.contains(categoryId)) {
      selected.remove(categoryId);
    } else {
      selected.add(categoryId);
    }
    state = state.copyWith(selectedCategoryIds: selected);
  }

  void initSelectedCategories(List<String> categoryIds) {
    state = state.copyWith(selectedCategoryIds: categoryIds.toSet());
  }

  Future<bool> saveCategories(String shopId) async {
    state = state.copyWith(status: CategoryStatus.saving);

    final useCase = ref.read(setShopCategoriesUseCaseProvider);
    final result = await useCase(SetShopCategoriesParams(
      shopId: shopId,
      categoryIds: state.selectedCategoryIds.toList(),
    ));

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: CategoryStatus.loaded,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(status: CategoryStatus.saved);
        return true;
      },
    );
  }
}

enum CategoryStatus { initial, loading, loaded, error, saving, saved }

class CategoryState extends Equatable {
  final CategoryStatus status;
  final List<Category> allCategories;
  final Set<String> selectedCategoryIds;
  final String? errorMessage;

  const CategoryState({
    this.status = CategoryStatus.initial,
    this.allCategories = const [],
    this.selectedCategoryIds = const {},
    this.errorMessage,
  });

  CategoryState copyWith({
    CategoryStatus? status,
    List<Category>? allCategories,
    Set<String>? selectedCategoryIds,
    String? errorMessage,
  }) {
    return CategoryState(
      status: status ?? this.status,
      allCategories: allCategories ?? this.allCategories,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, allCategories, selectedCategoryIds, errorMessage];
}
