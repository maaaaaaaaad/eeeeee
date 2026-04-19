import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile_owner/features/auth/presentation/providers/sign_up_provider.dart';

final withdrawalNotifierProvider =
    AutoDisposeNotifierProvider<WithdrawalNotifier, WithdrawalState>(
  () => WithdrawalNotifier(),
);

class WithdrawalNotifier extends AutoDisposeNotifier<WithdrawalState> {
  @override
  WithdrawalState build() {
    return const WithdrawalState();
  }

  void setEmail(String email) {
    state = state.copyWith(email: email);
  }

  void setPhoneNumber(String phone) {
    state = state.copyWith(phoneNumber: phone);
  }

  void setReason(String reason) {
    state = state.copyWith(reason: reason);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password);
  }

  void setConfirmText(String text) {
    state = state.copyWith(confirmText: text);
  }

  void toggleAgreement(int index) {
    final newAgreements = List<bool>.from(state.agreements);
    newAgreements[index] = !newAgreements[index];
    state = state.copyWith(agreements: newAgreements);
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
      purpose: 'WITHDRAW',
    );
    result.fold(
      (failure) => state = state.copyWith(
        emailStatus: VerificationStatus.initial,
        error: failure.message,
      ),
      (_) =>
          state = state.copyWith(emailStatus: VerificationStatus.codeSent),
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
      (_) => state = state.copyWith(smsStatus: VerificationStatus.codeSent),
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
      (token) => state = state.copyWith(
        smsStatus: VerificationStatus.verified,
        smsVerificationToken: token,
      ),
    );
  }

  Future<bool> submit() async {
    state = state.copyWith(
      withdrawStatus: WithdrawStatus.loading,
      error: null,
    );
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.withdraw(
      password: state.password,
      reason: state.reason,
      verificationToken: state.emailVerificationToken,
    );
    return result.fold(
      (failure) {
        state = state.copyWith(
          withdrawStatus: WithdrawStatus.error,
          error: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(withdrawStatus: WithdrawStatus.success);
        return true;
      },
    );
  }
}

enum WithdrawStatus { initial, loading, success, error }

class WithdrawalState extends Equatable {
  final String email;
  final String phoneNumber;
  final String reason;
  final String password;
  final String confirmText;
  final List<bool> agreements;
  final String emailVerificationToken;
  final String smsVerificationToken;
  final VerificationStatus emailStatus;
  final VerificationStatus smsStatus;
  final WithdrawStatus withdrawStatus;
  final String? error;

  const WithdrawalState({
    this.email = '',
    this.phoneNumber = '',
    this.reason = '',
    this.password = '',
    this.confirmText = '',
    this.agreements = const [false, false, false, false],
    this.emailVerificationToken = '',
    this.smsVerificationToken = '',
    this.emailStatus = VerificationStatus.initial,
    this.smsStatus = VerificationStatus.initial,
    this.withdrawStatus = WithdrawStatus.initial,
    this.error,
  });

  bool get allAgreed => agreements.every((e) => e);
  bool get confirmTextValid => confirmText.trim() == '회원탈퇴에 동의합니다';
  bool get isEmailVerified => emailStatus == VerificationStatus.verified;
  bool get isSmsVerified => smsStatus == VerificationStatus.verified;

  WithdrawalState copyWith({
    String? email,
    String? phoneNumber,
    String? reason,
    String? password,
    String? confirmText,
    List<bool>? agreements,
    String? emailVerificationToken,
    String? smsVerificationToken,
    VerificationStatus? emailStatus,
    VerificationStatus? smsStatus,
    WithdrawStatus? withdrawStatus,
    String? error,
  }) {
    return WithdrawalState(
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      reason: reason ?? this.reason,
      password: password ?? this.password,
      confirmText: confirmText ?? this.confirmText,
      agreements: agreements ?? this.agreements,
      emailVerificationToken:
          emailVerificationToken ?? this.emailVerificationToken,
      smsVerificationToken:
          smsVerificationToken ?? this.smsVerificationToken,
      emailStatus: emailStatus ?? this.emailStatus,
      smsStatus: smsStatus ?? this.smsStatus,
      withdrawStatus: withdrawStatus ?? this.withdrawStatus,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        email,
        phoneNumber,
        reason,
        password,
        confirmText,
        agreements,
        emailVerificationToken,
        smsVerificationToken,
        emailStatus,
        smsStatus,
        withdrawStatus,
        error,
      ];
}
