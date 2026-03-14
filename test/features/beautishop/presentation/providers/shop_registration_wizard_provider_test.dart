import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/create_shop_params.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/geocode_result.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/treatment_draft.dart';
import 'package:mobile_owner/features/beautishop/domain/usecases/check_reg_num_usecase.dart';
import 'package:mobile_owner/features/beautishop/domain/usecases/create_beautishop_usecase.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/beautishop_provider.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/shop_registration_wizard_provider.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';
import 'package:mobile_owner/features/treatment/domain/entities/create_treatment_params.dart';
import 'package:mobile_owner/features/treatment/domain/entities/treatment.dart';
import 'package:mobile_owner/features/treatment/domain/usecases/create_treatment_usecase.dart';
import 'package:mobile_owner/features/treatment/presentation/providers/treatment_provider.dart';

class MockCheckRegNumUseCase extends Mock implements CheckRegNumUseCase {}

class MockCreateBeautishopUseCase extends Mock
    implements CreateBeautishopUseCase {}

class MockCreateTreatmentUseCase extends Mock
    implements CreateTreatmentUseCase {}

void main() {
  late MockCheckRegNumUseCase mockCheckRegNum;
  late MockCreateBeautishopUseCase mockCreateBeautishop;
  late MockCreateTreatmentUseCase mockCreateTreatment;
  late ProviderContainer container;

  setUp(() {
    mockCheckRegNum = MockCheckRegNumUseCase();
    mockCreateBeautishop = MockCreateBeautishopUseCase();
    mockCreateTreatment = MockCreateTreatmentUseCase();

    container = ProviderContainer(overrides: [
      checkRegNumUseCaseProvider.overrideWithValue(mockCheckRegNum),
      createBeautishopUseCaseProvider.overrideWithValue(mockCreateBeautishop),
      createTreatmentUseCaseProvider.overrideWithValue(mockCreateTreatment),
    ]);
  });

  tearDown(() {
    container.dispose();
  });

  setUpAll(() {
    registerFallbackValue(
      const CreateTreatmentParams(
        shopId: '',
        name: '',
        price: 0,
        duration: 0,
      ),
    );
    registerFallbackValue(
      CreateShopParams(
        name: '',
        regNum: '',
        phoneNumber: '',
        address: '',
        latitude: 0,
        longitude: 0,
        operatingTime: const {},
      ),
    );
  });

  const testShop = BeautyShop(
    id: 'shop-1',
    name: '테스트 샵',
    regNum: '1234567890',
    phoneNumber: '01012345678',
    address: '서울시 강남구 테헤란로 123',
    latitude: 37.5665,
    longitude: 126.978,
    operatingTime: {'MONDAY': '09:00-18:00'},
    images: [],
    averageRating: 0.0,
    reviewCount: 0,
    categories: [],
  );

  final testTreatment = Treatment(
    id: 'treatment-1',
    shopId: 'shop-1',
    name: '커트',
    price: 15000,
    duration: 30,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  group('initial state', () {
    test('should have correct defaults', () {
      final state = container.read(shopRegistrationWizardProvider);

      expect(state.currentStep, 0);
      expect(state.submitStatus, SubmitStatus.initial);
      expect(state.shopName, '');
      expect(state.shopRegNum, '');
      expect(state.shopPhoneNumber, '');
      expect(state.regNumCheckStatus, RegNumCheckStatus.unchecked);
      expect(state.selectedLocation, isNull);
      expect(state.detailAddress, '');
      expect(state.operatingTime, isEmpty);
      expect(state.shopDescription, '');
      expect(state.shopImages, isEmpty);
      expect(state.treatmentDrafts, isEmpty);
    });
  });

  group('updateField', () {
    test('should update shopName', () {
      final notifier = container.read(shopRegistrationWizardProvider.notifier);
      notifier.updateShopName('뷰티샵');

      final state = container.read(shopRegistrationWizardProvider);
      expect(state.shopName, '뷰티샵');
    });

    test('should reset regNumCheckStatus when regNum changes', () {
      final notifier = container.read(shopRegistrationWizardProvider.notifier);
      notifier.updateShopRegNum('1234567890');

      final state = container.read(shopRegistrationWizardProvider);
      expect(state.shopRegNum, '1234567890');
      expect(state.regNumCheckStatus, RegNumCheckStatus.unchecked);
    });
  });

  group('checkRegNumAvailability', () {
    test('should set status to available when not duplicate', () async {
      when(() => mockCheckRegNum('1234567890'))
          .thenAnswer((_) async => const Right(null));

      final notifier = container.read(shopRegistrationWizardProvider.notifier);
      notifier.updateShopRegNum('1234567890');
      await notifier.checkRegNumAvailability();

      final state = container.read(shopRegistrationWizardProvider);
      expect(state.regNumCheckStatus, RegNumCheckStatus.available);
    });

    test('should set status to duplicate on ValidationFailure', () async {
      when(() => mockCheckRegNum('1234567890')).thenAnswer(
          (_) async => const Left(ValidationFailure('이미 등록된 사업자등록번호입니다')));

      final notifier = container.read(shopRegistrationWizardProvider.notifier);
      notifier.updateShopRegNum('1234567890');
      await notifier.checkRegNumAvailability();

      final state = container.read(shopRegistrationWizardProvider);
      expect(state.regNumCheckStatus, RegNumCheckStatus.duplicate);
    });

    test('should reset to unchecked on ServerFailure', () async {
      when(() => mockCheckRegNum('1234567890')).thenAnswer(
          (_) async => const Left(ServerFailure('서버 오류')));

      final notifier = container.read(shopRegistrationWizardProvider.notifier);
      notifier.updateShopRegNum('1234567890');
      await notifier.checkRegNumAvailability();

      final state = container.read(shopRegistrationWizardProvider);
      expect(state.regNumCheckStatus, RegNumCheckStatus.unchecked);
      expect(state.errorMessage, '서버 오류');
    });
  });

  group('step navigation', () {
    test('should return error message without valid basic info', () {
      final notifier = container.read(shopRegistrationWizardProvider.notifier);
      final result = notifier.nextStep();

      expect(result, isNotNull);
      expect(container.read(shopRegistrationWizardProvider).currentStep, 0);
    });

    test('should return regNum check message when fields valid but unchecked',
        () async {
      final notifier = container.read(shopRegistrationWizardProvider.notifier);
      notifier.updateShopName('뷰티샵');
      notifier.updateShopRegNum('1234567890');
      notifier.updateShopPhoneNumber('010-1234-5678');

      final result = notifier.nextStep();

      expect(result, contains('중복 확인'));
      expect(container.read(shopRegistrationWizardProvider).currentStep, 0);
    });

    test('should return null and advance with valid basic info', () async {
      when(() => mockCheckRegNum('1234567890'))
          .thenAnswer((_) async => const Right(null));

      final notifier = container.read(shopRegistrationWizardProvider.notifier);
      notifier.updateShopName('뷰티샵');
      notifier.updateShopRegNum('1234567890');
      notifier.updateShopPhoneNumber('010-1234-5678');
      await notifier.checkRegNumAvailability();

      final result = notifier.nextStep();

      expect(result, isNull);
      expect(container.read(shopRegistrationWizardProvider).currentStep, 1);
    });

    test('should go back to previous step', () async {
      when(() => mockCheckRegNum('1234567890'))
          .thenAnswer((_) async => const Right(null));

      final notifier = container.read(shopRegistrationWizardProvider.notifier);
      notifier.updateShopName('뷰티샵');
      notifier.updateShopRegNum('1234567890');
      notifier.updateShopPhoneNumber('010-1234-5678');
      await notifier.checkRegNumAvailability();
      notifier.nextStep();
      notifier.previousStep();

      expect(container.read(shopRegistrationWizardProvider).currentStep, 0);
    });

    test('should not go below step 0', () {
      final notifier = container.read(shopRegistrationWizardProvider.notifier);
      notifier.previousStep();

      expect(container.read(shopRegistrationWizardProvider).currentStep, 0);
    });
  });

  group('step 1→2 validation (location)', () {
    test('should require selectedLocation', () async {
      when(() => mockCheckRegNum('1234567890'))
          .thenAnswer((_) async => const Right(null));

      final notifier = container.read(shopRegistrationWizardProvider.notifier);
      notifier.updateShopName('뷰티샵');
      notifier.updateShopRegNum('1234567890');
      notifier.updateShopPhoneNumber('010-1234-5678');
      await notifier.checkRegNumAvailability();
      notifier.nextStep();

      final result = notifier.nextStep();
      expect(result, isNotNull);
    });
  });

  group('treatment drafts', () {
    test('should add treatment draft', () {
      final notifier = container.read(shopRegistrationWizardProvider.notifier);
      const draft = TreatmentDraft(name: '커트', price: 15000, duration: 30);
      notifier.addTreatmentDraft(draft);

      final state = container.read(shopRegistrationWizardProvider);
      expect(state.treatmentDrafts.length, 1);
      expect(state.treatmentDrafts.first.name, '커트');
    });

    test('should remove treatment draft', () {
      final notifier = container.read(shopRegistrationWizardProvider.notifier);
      const draft = TreatmentDraft(name: '커트', price: 15000, duration: 30);
      notifier.addTreatmentDraft(draft);
      notifier.removeTreatmentDraft(0);

      final state = container.read(shopRegistrationWizardProvider);
      expect(state.treatmentDrafts, isEmpty);
    });

    test('should update treatment draft', () {
      final notifier = container.read(shopRegistrationWizardProvider.notifier);
      const draft = TreatmentDraft(name: '커트', price: 15000, duration: 30);
      notifier.addTreatmentDraft(draft);

      const updated = TreatmentDraft(name: '커트', price: 20000, duration: 30);
      notifier.updateTreatmentDraft(0, updated);

      final state = container.read(shopRegistrationWizardProvider);
      expect(state.treatmentDrafts.first.price, 20000);
    });
  });

  group('goToStep', () {
    test('should jump to a specific step', () {
      final notifier = container.read(shopRegistrationWizardProvider.notifier);
      notifier.goToStep(2);

      expect(container.read(shopRegistrationWizardProvider).currentStep, 2);
    });
  });

  group('submit', () {
    test('should create shop and treatments on success', () async {
      when(() => mockCheckRegNum('1234567890'))
          .thenAnswer((_) async => const Right(null));
      when(() => mockCreateBeautishop(any()))
          .thenAnswer((_) async => const Right(testShop));
      when(() => mockCreateTreatment(any()))
          .thenAnswer((_) async => Right(testTreatment));

      final notifier = container.read(shopRegistrationWizardProvider.notifier);
      notifier.updateShopName('테스트 샵');
      notifier.updateShopRegNum('1234567890');
      notifier.updateShopPhoneNumber('010-1234-5678');
      await notifier.checkRegNumAvailability();
      notifier.updateSelectedLocation(const GeocodeResult(
        roadAddress: '서울시 강남구 테헤란로 123',
        jibunAddress: '',
        latitude: 37.5665,
        longitude: 126.978,
      ));
      notifier.updateOperatingTime({'MONDAY': '09:00-18:00'});
      notifier.updateShopDescription('좋은 샵');
      notifier.addTreatmentDraft(
        const TreatmentDraft(name: '커트', price: 15000, duration: 30),
      );

      await notifier.submit();

      final state = container.read(shopRegistrationWizardProvider);
      expect(state.submitStatus, SubmitStatus.success);
      expect(state.createdShop, testShop);
    });

    test('should set error when shop creation fails', () async {
      when(() => mockCreateBeautishop(any()))
          .thenAnswer((_) async => const Left(ServerFailure('생성 실패')));

      final notifier = container.read(shopRegistrationWizardProvider.notifier);
      notifier.updateShopName('테스트 샵');
      notifier.updateShopRegNum('1234567890');
      notifier.updateShopPhoneNumber('010-1234-5678');
      notifier.updateSelectedLocation(const GeocodeResult(
        roadAddress: '서울시 강남구 테헤란로 123',
        jibunAddress: '',
        latitude: 37.5665,
        longitude: 126.978,
      ));
      notifier.updateOperatingTime({'MONDAY': '09:00-18:00'});
      notifier.updateShopDescription('좋은 샵');
      notifier.addTreatmentDraft(
        const TreatmentDraft(name: '커트', price: 15000, duration: 30),
      );

      await notifier.submit();

      final state = container.read(shopRegistrationWizardProvider);
      expect(state.submitStatus, SubmitStatus.error);
      expect(state.errorMessage, '생성 실패');
    });

    test('should set partialSuccess when treatment creation fails', () async {
      when(() => mockCreateBeautishop(any()))
          .thenAnswer((_) async => const Right(testShop));
      when(() => mockCreateTreatment(any()))
          .thenAnswer((_) async => const Left(ServerFailure('시술 생성 실패')));

      final notifier = container.read(shopRegistrationWizardProvider.notifier);
      notifier.updateShopName('테스트 샵');
      notifier.updateShopRegNum('1234567890');
      notifier.updateShopPhoneNumber('010-1234-5678');
      notifier.updateSelectedLocation(const GeocodeResult(
        roadAddress: '서울시 강남구 테헤란로 123',
        jibunAddress: '',
        latitude: 37.5665,
        longitude: 126.978,
      ));
      notifier.updateOperatingTime({'MONDAY': '09:00-18:00'});
      notifier.updateShopDescription('좋은 샵');
      notifier.addTreatmentDraft(
        const TreatmentDraft(name: '커트', price: 15000, duration: 30),
      );

      await notifier.submit();

      final state = container.read(shopRegistrationWizardProvider);
      expect(state.submitStatus, SubmitStatus.partialSuccess);
      expect(state.createdShop, testShop);
    });
  });
}
