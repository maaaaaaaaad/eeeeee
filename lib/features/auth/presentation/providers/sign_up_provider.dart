import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:mobile_owner/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile_owner/shared/utils/input_formatters.dart';

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignUpUseCase(repository);
});

final signUpNotifierProvider =
    NotifierProvider<SignUpNotifier, SignUpState>(() {
  return SignUpNotifier();
});

class SignUpNotifier extends Notifier<SignUpState> {
  @override
  SignUpState build() {
    return const SignUpState();
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  void updateBusinessNumber(String businessNumber) {
    state = state.copyWith(businessNumber: businessNumber);
  }

  void updatePhoneNumber(String phoneNumber) {
    state = state.copyWith(phoneNumber: phoneNumber);
  }

  void updateNickname(String nickname) {
    state = state.copyWith(nickname: nickname);
  }

  void nextStep() {
    if (state.currentStep < 2) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  Future<void> submit() async {
    state = state.copyWith(status: SignUpStatus.loading);

    final signUpUseCase = ref.read(signUpUseCaseProvider);

    final result = await signUpUseCase(SignUpParams(
      email: state.email,
      password: state.password,
      businessNumber: BusinessNumberFormatter.stripHyphens(state.businessNumber),
      phoneNumber: PhoneNumberFormatter.stripHyphens(state.phoneNumber),
      nickname: state.nickname,
    ));

    result.fold(
      (failure) => state = state.copyWith(
        status: SignUpStatus.error,
        errorMessage: failure.message,
      ),
      (token) => state = state.copyWith(status: SignUpStatus.success),
    );
  }

  void reset() {
    state = const SignUpState();
  }
}

class SignUpState extends Equatable {
  final int currentStep;
  final String email;
  final String password;
  final String businessNumber;
  final String phoneNumber;
  final String nickname;
  final SignUpStatus status;
  final String? errorMessage;

  const SignUpState({
    this.currentStep = 0,
    this.email = '',
    this.password = '',
    this.businessNumber = '',
    this.phoneNumber = '',
    this.nickname = '',
    this.status = SignUpStatus.initial,
    this.errorMessage,
  });

  SignUpState copyWith({
    int? currentStep,
    String? email,
    String? password,
    String? businessNumber,
    String? phoneNumber,
    String? nickname,
    SignUpStatus? status,
    String? errorMessage,
  }) {
    return SignUpState(
      currentStep: currentStep ?? this.currentStep,
      email: email ?? this.email,
      password: password ?? this.password,
      businessNumber: businessNumber ?? this.businessNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      nickname: nickname ?? this.nickname,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => status == SignUpStatus.loading;
  bool get isSuccess => status == SignUpStatus.success;
  bool get hasError => status == SignUpStatus.error;

  @override
  List<Object?> get props => [
        currentStep,
        email,
        password,
        businessNumber,
        phoneNumber,
        nickname,
        status,
        errorMessage,
      ];
}

enum SignUpStatus {
  initial,
  loading,
  success,
  error,
}
