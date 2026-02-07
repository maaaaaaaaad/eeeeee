import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/category.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/create_shop_params.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/update_shop_params.dart';
import 'package:mobile_owner/features/beautishop/domain/repositories/beautishop_repository.dart';
import 'package:mobile_owner/features/beautishop/domain/usecases/create_beautishop_usecase.dart';
import 'package:mobile_owner/features/beautishop/domain/usecases/delete_beautishop_usecase.dart';
import 'package:mobile_owner/features/beautishop/domain/usecases/get_beautishop_usecase.dart';
import 'package:mobile_owner/features/beautishop/domain/usecases/get_categories_usecase.dart';
import 'package:mobile_owner/features/beautishop/domain/usecases/set_shop_categories_usecase.dart';
import 'package:mobile_owner/features/beautishop/domain/usecases/update_beautishop_usecase.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';

class MockBeautishopRepository extends Mock implements BeautishopRepository {}

void main() {
  late MockBeautishopRepository mockRepository;

  setUp(() {
    mockRepository = MockBeautishopRepository();
  });

  const testShop = BeautyShop(
    id: 'shop-1',
    name: '테스트 샵',
    regNum: '1234567890',
    phoneNumber: '01012345678',
    address: '서울시 강남구',
    latitude: 37.5665,
    longitude: 126.978,
    operatingTime: {'MONDAY': '09:00-18:00'},
    images: [],
    averageRating: 0.0,
    reviewCount: 0,
    categories: [],
  );

  group('CreateBeautishopUseCase', () {
    late CreateBeautishopUseCase useCase;

    setUp(() {
      useCase = CreateBeautishopUseCase(mockRepository);
    });

    final params = CreateShopParams(
      name: '테스트 샵',
      regNum: '1234567890',
      phoneNumber: '01012345678',
      address: '서울시 강남구',
      latitude: 37.5665,
      longitude: 126.978,
      operatingTime: const {'MONDAY': '09:00-18:00'},
    );

    test('should create a shop via repository', () async {
      when(() => mockRepository.createShop(params))
          .thenAnswer((_) async => const Right(testShop));

      final result = await useCase(params);

      expect(result, const Right(testShop));
      verify(() => mockRepository.createShop(params)).called(1);
    });

    test('should return failure when creation fails', () async {
      when(() => mockRepository.createShop(params))
          .thenAnswer((_) async => const Left(ServerFailure('생성 실패')));

      final result = await useCase(params);

      expect(result, const Left(ServerFailure('생성 실패')));
    });
  });

  group('GetBeautishopUseCase', () {
    late GetBeautishopUseCase useCase;

    setUp(() {
      useCase = GetBeautishopUseCase(mockRepository);
    });

    test('should get a shop by id', () async {
      when(() => mockRepository.getShop('shop-1'))
          .thenAnswer((_) async => const Right(testShop));

      final result = await useCase('shop-1');

      expect(result, const Right(testShop));
      verify(() => mockRepository.getShop('shop-1')).called(1);
    });

    test('should return failure when shop not found', () async {
      when(() => mockRepository.getShop('invalid'))
          .thenAnswer((_) async => const Left(ServerFailure('샵을 찾을 수 없습니다')));

      final result = await useCase('invalid');

      expect(result.isLeft(), true);
    });
  });

  group('UpdateBeautishopUseCase', () {
    late UpdateBeautishopUseCase useCase;

    setUp(() {
      useCase = UpdateBeautishopUseCase(mockRepository);
    });

    final params = UpdateShopParams(
      shopId: 'shop-1',
      operatingTime: const {'MONDAY': '10:00-20:00'},
      shopImages: const [],
    );

    test('should update a shop via repository', () async {
      when(() => mockRepository.updateShop(params))
          .thenAnswer((_) async => const Right(testShop));

      final result = await useCase(params);

      expect(result, const Right(testShop));
      verify(() => mockRepository.updateShop(params)).called(1);
    });
  });

  group('DeleteBeautishopUseCase', () {
    late DeleteBeautishopUseCase useCase;

    setUp(() {
      useCase = DeleteBeautishopUseCase(mockRepository);
    });

    test('should delete a shop via repository', () async {
      when(() => mockRepository.deleteShop('shop-1'))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase('shop-1');

      expect(result, const Right(null));
      verify(() => mockRepository.deleteShop('shop-1')).called(1);
    });
  });

  group('GetCategoriesUseCase', () {
    late GetCategoriesUseCase useCase;

    setUp(() {
      useCase = GetCategoriesUseCase(mockRepository);
    });

    const categories = [
      Category(id: '1', name: '네일'),
      Category(id: '2', name: '헤어'),
    ];

    test('should get all categories', () async {
      when(() => mockRepository.getCategories())
          .thenAnswer((_) async => const Right(categories));

      final result = await useCase(NoParams());

      expect(result, const Right(categories));
      verify(() => mockRepository.getCategories()).called(1);
    });
  });

  group('SetShopCategoriesUseCase', () {
    late SetShopCategoriesUseCase useCase;

    setUp(() {
      useCase = SetShopCategoriesUseCase(mockRepository);
    });

    test('should set categories for a shop', () async {
      const params = SetShopCategoriesParams(
        shopId: 'shop-1',
        categoryIds: ['1', '2'],
      );
      when(() => mockRepository.setShopCategories('shop-1', ['1', '2']))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(params);

      expect(result, const Right(null));
      verify(() => mockRepository.setShopCategories('shop-1', ['1', '2']))
          .called(1);
    });
  });
}
