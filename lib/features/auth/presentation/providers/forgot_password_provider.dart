import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile_owner/features/auth/presentation/providers/sign_up_provider.dart';

final forgotPasswordNotifierProvider =
    AutoDisposeNotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>(
  () => ForgotPasswordNotifier(),
);

class ForgotPasswordNotifier extends AutoDisposeNotifier<ForgotPasswordState> {
  @override
  ForgotPasswordState build() {
    return const ForgotPasswordState();
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePhoneNumber(String phone) {
    state = state.copyWith(phoneNumber: phone);
  }

  Future<void> sendEmailCode() async {
    if (state.email.isEmpty) return;

    state = state.copyWith(
      emailStatus: VerificationStatus.sending,
      error: null,
    );

    final repository = ref.read(authRepositoryProvider);
    final result = await repository.sendVerificationCode(
      state.email,
      purpose: 'RESET_PASSWORD',
    );

    result.fold(
      (failure) => state = state.copyWith(
        emailStatus: VerificationStatus.initial,
        error: failure.message,
      ),
      (_) => state = state.copyWith(
        emailStatus: VerificationStatus.codeSent,
      ),
    );
  }

  Future<void> verifyEmailCode(String code) async {
    state = state.copyWith(
      emailStatus: VerificationStatus.verifying,
      error: null,
    );

    final repository = ref.read(authRepositoryProvider);
    final result = await repository.verifyCode(state.email, code);

    result.fold(
      (failure) => state = state.copyWith(
        emailStatus: VerificationStatus.codeSent,
        error: failure.message,
      ),
      (token) => state = state.copyWith(
        emailStatus: VerificationStatus.verified,
        emailVerificationToken: token,
      ),
    );
  }

  Future<void> sendSmsCode() async {
    if (state.phoneNumber.isEmpty) return;

    state = state.copyWith(
      smsStatus: VerificationStatus.sending,
      error: null,
    );

    final repository = ref.read(authRepositoryProvider);
    final result = await repository.sendSmsVerificationCode(state.phoneNumber);

    result.fold(
      (failure) => state = state.copyWith(
        smsStatus: VerificationStatus.initial,
        error: failure.message,
      ),
      (_) => state = state.copyWith(
        smsStatus: VerificationStatus.codeSent,
      ),
    );
  }

  Future<void> verifySmsCode(String code) async {
    state = state.copyWith(
      smsStatus: VerificationStatus.verifying,
      error: null,
    );

    final repository = ref.read(authRepositoryProvider);
    final result = await repository.verifySmsCode(state.phoneNumber, code);

    result.fold(
      (failure) => state = state.copyWith(
        smsStatus: VerificationStatus.codeSent,
        error: failure.message,
      ),
      (_) => state = state.copyWith(
        smsStatus: VerificationStatus.verified,
      ),
    );
  }

  Future<void> resetPassword(String newPassword) async {
    state = state.copyWith(
      resetStatus: ResetPasswordStatus.loading,
      error: null,
    );

    final repository = ref.read(authRepositoryProvider);
    final result = await repository.resetPassword(
      email: state.email,
      newPassword: newPassword,
      emailVerificationToken: state.emailVerificationToken,
    );

    result.fold(
      (failure) => state = state.copyWith(
        resetStatus: ResetPasswordStatus.error,
        error: failure.message,
      ),
      (_) => state = state.copyWith(
        resetStatus: ResetPasswordStatus.success,
      ),
    );
  }
}

enum ResetPasswordStatus { initial, loading, success, error }

class ForgotPasswordState extends Equatable {
  final String email;
  final String phoneNumber;
  final String emailVerificationToken;
  final VerificationStatus emailStatus;
  final VerificationStatus smsStatus;
  final ResetPasswordStatus resetStatus;
  final String? error;

  const ForgotPasswordState({
    this.email = '',
    this.phoneNumber = '',
    this.emailVerificationToken = '',
    this.emailStatus = VerificationStatus.initial,
    this.smsStatus = VerificationStatus.initial,
    this.resetStatus = ResetPasswordStatus.initial,
    this.error,
  });

  bool get isEmailVerified => emailStatus == VerificationStatus.verified;
  bool get isSmsVerified => smsStatus == VerificationStatus.verified;

  ForgotPasswordState copyWith({
    String? email,
    String? phoneNumber,
    String? emailVerificationToken,
    VerificationStatus? emailStatus,
    VerificationStatus? smsStatus,
    ResetPasswordStatus? resetStatus,
    String? error,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailVerificationToken: emailVerificationToken ?? this.emailVerificationToken,
      emailStatus: emailStatus ?? this.emailStatus,
      smsStatus: smsStatus ?? this.smsStatus,
      resetStatus: resetStatus ?? this.resetStatus,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        email,
        phoneNumber,
        emailVerificationToken,
        emailStatus,
        smsStatus,
        resetStatus,
        error,
      ];
}
