import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/category.dart';
import 'package:mobile_owner/features/beautishop/domain/usecases/get_categories_usecase.dart';
import 'package:mobile_owner/features/beautishop/domain/usecases/set_shop_categories_usecase.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/beautishop_provider.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/category_provider.dart';

class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

class MockSetShopCategoriesUseCase extends Mock
    implements SetShopCategoriesUseCase {}

void main() {
  late MockGetCategoriesUseCase mockGetCategories;
  late MockSetShopCategoriesUseCase mockSetCategories;

  setUp(() {
    mockGetCategories = MockGetCategoriesUseCase();
    mockSetCategories = MockSetShopCategoriesUseCase();
  });

  setUpAll(() {
    registerFallbackValue(NoParams());
    registerFallbackValue(const SetShopCategoriesParams(
      shopId: '',
      categoryIds: [],
    ));
  });

  const categories = [
    Category(id: '1', name: '네일'),
    Category(id: '2', name: '헤어'),
    Category(id: '3', name: '피부'),
  ];

  ProviderContainer createContainer() {
    when(() => mockGetCategories(any()))
        .thenAnswer((_) async => const Right(categories));

    return ProviderContainer(
      overrides: [
        getCategoriesUseCaseProvider.overrideWithValue(mockGetCategories),
        setShopCategoriesUseCaseProvider.overrideWithValue(mockSetCategories),
      ],
    );
  }

  group('CategoryNotifier', () {
    test('should load categories via loadCategories', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(categoryNotifierProvider.notifier);
      await notifier.loadCategories();

      final state = container.read(categoryNotifierProvider);
      expect(state.status, CategoryStatus.loaded);
      expect(state.allCategories.length, 3);
    });

    test('should toggle category selection', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(categoryNotifierProvider.notifier);
      await notifier.loadCategories();

      notifier.toggleCategory('1');
      expect(
        container.read(categoryNotifierProvider).selectedCategoryIds,
        {'1'},
      );

      notifier.toggleCategory('2');
      expect(
        container.read(categoryNotifierProvider).selectedCategoryIds,
        {'1', '2'},
      );

      notifier.toggleCategory('1');
      expect(
        container.read(categoryNotifierProvider).selectedCategoryIds,
        {'2'},
      );
    });

    test('should initialize with pre-selected categories', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(categoryNotifierProvider.notifier);
      await notifier.loadCategories();

      notifier.initSelectedCategories(['1', '3']);

      expect(
        container.read(categoryNotifierProvider).selectedCategoryIds,
        {'1', '3'},
      );
    });

    test('should save categories successfully', () async {
      when(() => mockSetCategories(any()))
          .thenAnswer((_) async => const Right(null));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(categoryNotifierProvider.notifier);
      await notifier.loadCategories();

      notifier.toggleCategory('1');

      final result = await notifier.saveCategories('shop-1');

      expect(result, true);
      expect(
        container.read(categoryNotifierProvider).status,
        CategoryStatus.saved,
      );
    });

    test('should handle save failure', () async {
      when(() => mockSetCategories(any()))
          .thenAnswer((_) async => const Left(ServerFailure('저장 실패')));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(categoryNotifierProvider.notifier);
      await notifier.loadCategories();

      final result = await notifier.saveCategories('shop-1');

      expect(result, false);
      expect(
        container.read(categoryNotifierProvider).errorMessage,
        '저장 실패',
      );
    });
  });
}
