import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/create_shop_params.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/geocode_result.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/treatment_draft.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/beautishop_provider.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';
import 'package:mobile_owner/features/treatment/domain/entities/create_treatment_params.dart';
import 'package:mobile_owner/features/treatment/presentation/providers/treatment_provider.dart';
import 'package:mobile_owner/shared/utils/validators.dart';

final shopRegistrationWizardProvider = AutoDisposeNotifierProvider<
    ShopRegistrationWizardNotifier, ShopRegistrationWizardState>(
  () => ShopRegistrationWizardNotifier(),
);

class ShopRegistrationWizardNotifier
    extends AutoDisposeNotifier<ShopRegistrationWizardState> {
  static const int totalSteps = 6;

  @override
  ShopRegistrationWizardState build() {
    return const ShopRegistrationWizardState();
  }

  void updateShopName(String value) {
    state = state.copyWith(shopName: value);
  }

  void updateShopRegNum(String value) {
    state = state.copyWith(
      shopRegNum: value,
      regNumCheckStatus: RegNumCheckStatus.unchecked,
    );
  }

  void updateShopPhoneNumber(String value) {
    state = state.copyWith(shopPhoneNumber: value);
  }

  void updateSelectedLocation(GeocodeResult? location) {
    state = state.copyWith(
      selectedLocation: location,
      clearSelectedLocation: location == null,
    );
  }

  void updateDetailAddress(String value) {
    state = state.copyWith(detailAddress: value);
  }

  void updateOperatingTime(Map<String, String> value) {
    state = state.copyWith(operatingTime: value);
  }

  void updateShopDescription(String value) {
    state = state.copyWith(shopDescription: value);
  }

  void updateShopImages(List<String> value) {
    state = state.copyWith(shopImages: value);
  }

  void addTreatmentDraft(TreatmentDraft draft) {
    state = state.copyWith(
      treatmentDrafts: [...state.treatmentDrafts, draft],
    );
  }

  void removeTreatmentDraft(int index) {
    final drafts = [...state.treatmentDrafts];
    drafts.removeAt(index);
    state = state.copyWith(treatmentDrafts: drafts);
  }

  void updateTreatmentDraft(int index, TreatmentDraft draft) {
    final drafts = [...state.treatmentDrafts];
    drafts[index] = draft;
    state = state.copyWith(treatmentDrafts: drafts);
  }

  Future<void> checkRegNumAvailability() async {
    if (state.shopRegNum.trim().isEmpty) return;

    state = state.copyWith(regNumCheckStatus: RegNumCheckStatus.checking);

    final useCase = ref.read(checkRegNumUseCaseProvider);
    final result = await useCase(state.shopRegNum.trim());

    result.fold(
      (failure) {
        if (failure is ValidationFailure) {
          state = state.copyWith(
            regNumCheckStatus: RegNumCheckStatus.duplicate,
          );
        } else {
          state = state.copyWith(
            regNumCheckStatus: RegNumCheckStatus.unchecked,
            errorMessage: failure.message,
          );
        }
      },
      (_) => state = state.copyWith(
        regNumCheckStatus: RegNumCheckStatus.available,
      ),
    );
  }

  String? nextStep() {
    final error = _validateCurrentStep();
    if (error != null) return error;
    if (state.currentStep < totalSteps - 1) {
      state = state.copyWith(currentStep: state.currentStep + 1);
      return null;
    }
    return null;
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      state = state.copyWith(currentStep: step);
    }
  }

  String? _validateCurrentStep() {
    switch (state.currentStep) {
      case 0:
        return _validateBasicInfo();
      case 1:
        return _validateLocation();
      case 2:
        return _validateOperatingTime();
      case 3:
        return _validateDescription();
      case 4:
        return _validateTreatments();
      default:
        return null;
    }
  }

  String? _validateBasicInfo() {
    if (ShopNameValidator.validate(state.shopName.trim()) != null) {
      return ShopNameValidator.validate(state.shopName.trim());
    }
    if (BusinessNumberValidator.validate(state.shopRegNum.trim()) != null) {
      return BusinessNumberValidator.validate(state.shopRegNum.trim());
    }
    if (PhoneNumberValidator.validate(state.shopPhoneNumber.trim()) != null) {
      return PhoneNumberValidator.validate(state.shopPhoneNumber.trim());
    }
    if (state.regNumCheckStatus != RegNumCheckStatus.available) {
      return '사업자등록번호 중복 확인을 해주세요';
    }
    return null;
  }

  String? _validateLocation() {
    if (state.selectedLocation == null) return '위치를 선택해주세요';
    final combinedAddress = _buildCombinedAddress();
    if (combinedAddress.length < 5 || combinedAddress.length > 200) {
      return '주소는 5자 이상 200자 이하여야 합니다';
    }
    return null;
  }

  String? _validateOperatingTime() {
    if (state.operatingTime.isEmpty) return '영업 시간을 설정해주세요';
    return null;
  }

  String? _validateDescription() {
    if (state.shopDescription.trim().isEmpty) return '샵 설명을 입력해주세요';
    return null;
  }

  String? _validateTreatments() {
    if (state.treatmentDrafts.isEmpty) return '최소 1개 이상의 시술을 등록해주세요';
    return null;
  }

  String _buildCombinedAddress() {
    final base = state.selectedLocation?.displayAddress ?? '';
    final detail = state.detailAddress.trim();
    if (detail.isEmpty) return base;
    return '$base $detail';
  }

  Future<void> submit() async {
    state = state.copyWith(submitStatus: SubmitStatus.loading);

    final shopParams = CreateShopParams(
      name: state.shopName.trim(),
      regNum: state.shopRegNum.trim(),
      phoneNumber:
          PhoneNumberFormatter.format(state.shopPhoneNumber.trim()),
      address: _buildCombinedAddress(),
      latitude: state.selectedLocation!.latitude,
      longitude: state.selectedLocation!.longitude,
      operatingTime: state.operatingTime,
      shopDescription: state.shopDescription.trim().isEmpty
          ? null
          : state.shopDescription.trim(),
      shopImages: state.shopImages,
    );

    final createShopUseCase = ref.read(createBeautishopUseCaseProvider);
    final shopResult = await createShopUseCase(shopParams);

    await shopResult.fold(
      (failure) async {
        state = state.copyWith(
          submitStatus: SubmitStatus.error,
          errorMessage: failure.message,
        );
      },
      (shop) async {
        state = state.copyWith(createdShop: shop);

        final createTreatmentUseCase =
            ref.read(createTreatmentUseCaseProvider);
        var hasFailure = false;

        for (final draft in state.treatmentDrafts) {
          final treatmentParams = CreateTreatmentParams(
            shopId: shop.id,
            name: draft.name,
            price: draft.price,
            duration: draft.duration,
            description: draft.description,
          );

          final treatmentResult =
              await createTreatmentUseCase(treatmentParams);
          treatmentResult.fold(
            (_) => hasFailure = true,
            (_) {},
          );
        }

        if (hasFailure) {
          state = state.copyWith(submitStatus: SubmitStatus.partialSuccess);
        } else {
          state = state.copyWith(submitStatus: SubmitStatus.success);
        }
      },
    );
  }
}

enum SubmitStatus { initial, loading, success, partialSuccess, error }

enum RegNumCheckStatus { unchecked, checking, available, duplicate }

class ShopRegistrationWizardState extends Equatable {
  final int currentStep;
  final SubmitStatus submitStatus;
  final String? errorMessage;
  final BeautyShop? createdShop;

  final String shopName;
  final String shopRegNum;
  final String shopPhoneNumber;
  final RegNumCheckStatus regNumCheckStatus;

  final GeocodeResult? selectedLocation;
  final String detailAddress;

  final Map<String, String> operatingTime;

  final String shopDescription;
  final List<String> shopImages;

  final List<TreatmentDraft> treatmentDrafts;

  const ShopRegistrationWizardState({
    this.currentStep = 0,
    this.submitStatus = SubmitStatus.initial,
    this.errorMessage,
    this.createdShop,
    this.shopName = '',
    this.shopRegNum = '',
    this.shopPhoneNumber = '',
    this.regNumCheckStatus = RegNumCheckStatus.unchecked,
    this.selectedLocation,
    this.detailAddress = '',
    this.operatingTime = const {},
    this.shopDescription = '',
    this.shopImages = const [],
    this.treatmentDrafts = const [],
  });

  ShopRegistrationWizardState copyWith({
    int? currentStep,
    SubmitStatus? submitStatus,
    String? errorMessage,
    BeautyShop? createdShop,
    String? shopName,
    String? shopRegNum,
    String? shopPhoneNumber,
    RegNumCheckStatus? regNumCheckStatus,
    GeocodeResult? selectedLocation,
    bool clearSelectedLocation = false,
    String? detailAddress,
    Map<String, String>? operatingTime,
    String? shopDescription,
    List<String>? shopImages,
    List<TreatmentDraft>? treatmentDrafts,
  }) {
    return ShopRegistrationWizardState(
      currentStep: currentStep ?? this.currentStep,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      createdShop: createdShop ?? this.createdShop,
      shopName: shopName ?? this.shopName,
      shopRegNum: shopRegNum ?? this.shopRegNum,
      shopPhoneNumber: shopPhoneNumber ?? this.shopPhoneNumber,
      regNumCheckStatus: regNumCheckStatus ?? this.regNumCheckStatus,
      selectedLocation: clearSelectedLocation
          ? null
          : (selectedLocation ?? this.selectedLocation),
      detailAddress: detailAddress ?? this.detailAddress,
      operatingTime: operatingTime ?? this.operatingTime,
      shopDescription: shopDescription ?? this.shopDescription,
      shopImages: shopImages ?? this.shopImages,
      treatmentDrafts: treatmentDrafts ?? this.treatmentDrafts,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        submitStatus,
        errorMessage,
        createdShop,
        shopName,
        shopRegNum,
        shopPhoneNumber,
        regNumCheckStatus,
        selectedLocation,
        detailAddress,
        operatingTime,
        shopDescription,
        shopImages,
        treatmentDrafts,
      ];
}
