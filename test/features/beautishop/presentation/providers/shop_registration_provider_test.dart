import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/create_shop_params.dart';
import 'package:mobile_owner/features/beautishop/domain/usecases/create_beautishop_usecase.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/beautishop_provider.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/shop_registration_provider.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';

class MockCreateBeautishopUseCase extends Mock
    implements CreateBeautishopUseCase {}

void main() {
  late MockCreateBeautishopUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockCreateBeautishopUseCase();
  });

  setUpAll(() {
    registerFallbackValue(CreateShopParams(
      name: '',
      regNum: '',
      phoneNumber: '',
      address: '',
      latitude: 0,
      longitude: 0,
      operatingTime: const {},
    ));
  });

  const testShop = BeautyShop(
    id: 'shop-1',
    name: '테스트 샵',
    regNum: '1234567890',
    phoneNumber: '01012345678',
    address: '서울시 강남구',
    latitude: 37.5665,
    longitude: 126.978,
    operatingTime: {},
    images: [],
    averageRating: 0.0,
    reviewCount: 0,
    categories: [],
  );

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        createBeautishopUseCaseProvider.overrideWithValue(mockUseCase),
      ],
    );
  }

  group('ShopRegistrationNotifier', () {
    test('initial state should be initial status', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final state = container.read(shopRegistrationNotifierProvider);
      expect(state.status, ShopRegistrationStatus.initial);
    });

    test('should set success state when registration succeeds', () async {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => const Right(testShop));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(shopRegistrationNotifierProvider.notifier);

      await notifier.register(CreateShopParams(
        name: '테스트 샵',
        regNum: '1234567890',
        phoneNumber: '01012345678',
        address: '서울시 강남구',
        latitude: 37.5665,
        longitude: 126.978,
        operatingTime: const {},
      ));

      final state = container.read(shopRegistrationNotifierProvider);
      expect(state.status, ShopRegistrationStatus.success);
      expect(state.createdShop, testShop);
    });

    test('should set error state when registration fails', () async {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => const Left(ServerFailure('등록 실패')));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(shopRegistrationNotifierProvider.notifier);

      await notifier.register(CreateShopParams(
        name: '테스트 샵',
        regNum: '1234567890',
        phoneNumber: '01012345678',
        address: '서울시 강남구',
        latitude: 37.5665,
        longitude: 126.978,
        operatingTime: const {},
      ));

      final state = container.read(shopRegistrationNotifierProvider);
      expect(state.status, ShopRegistrationStatus.error);
      expect(state.errorMessage, '등록 실패');
    });
  });
}
