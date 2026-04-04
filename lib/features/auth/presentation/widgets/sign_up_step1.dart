import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/auth/presentation/providers/sign_up_provider.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class SignUpStep1 extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const SignUpStep1({super.key, required this.onNext});

  @override
  ConsumerState<SignUpStep1> createState() => _SignUpStep1State();
}

class _SignUpStep1State extends ConsumerState<SignUpStep1> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _codeController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  Timer? _resendTimer;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    final state = ref.read(signUpNotifierProvider);
    _emailController.text = state.email;
    _passwordController.text = state.password;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _codeController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    _resendCooldown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) timer.cancel();
      });
    });
  }

  void _onSendCode() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('올바른 이메일을 입력해주세요')),
      );
      return;
    }

    ref.read(signUpNotifierProvider.notifier).updateEmail(email);
    ref.read(signUpNotifierProvider.notifier).sendVerificationCode();
    _startResendCooldown();
  }

  void _onVerifyCode() {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('6자리 인증코드를 입력해주세요')),
      );
      return;
    }
    ref.read(signUpNotifierProvider.notifier).verifyCode(code);
  }

  void _onNext() {
    if (_formKey.currentState?.validate() ?? false) {
      final notifier = ref.read(signUpNotifierProvider.notifier);
      notifier.updatePassword(_passwordController.text);
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final signUpState = ref.watch(signUpNotifierProvider);
    final isVerified = signUpState.isEmailVerified;
    final verificationStatus = signUpState.verificationStatus;
    final showCodeInput = verificationStatus == VerificationStatus.codeSent ||
        verificationStatus == VerificationStatus.verifying;

    ref.listen<SignUpState>(signUpNotifierProvider, (prev, next) {
      if (next.verificationError != null &&
          next.verificationError != prev?.verificationError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.verificationError!)),
        );
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '이메일과 비밀번호를\n입력해주세요',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '로그인에 사용할 계정 정보입니다',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    readOnly: isVerified,
                    decoration: InputDecoration(
                      labelText: '이메일',
                      hintText: 'example@email.com',
                      prefixIcon: Icon(
                        isVerified ? Icons.check_circle : Icons.email_outlined,
                        color: isVerified ? Colors.green : null,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이메일을 입력해주세요';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return '올바른 이메일 형식이 아닙니다';
                      }
                      if (!isVerified) {
                        return '이메일 인증을 완료해주세요';
                      }
                      return null;
                    },
                  ),
                ),
                if (!isVerified) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 56,
                    child: FilledButton(
                      onPressed: verificationStatus == VerificationStatus.sending ||
                              _resendCooldown > 0
                          ? null
                          : _onSendCode,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: verificationStatus == VerificationStatus.sending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _resendCooldown > 0
                                  ? '${_resendCooldown}s'
                                  : showCodeInput
                                      ? '재전송'
                                      : '인증',
                              style: const TextStyle(fontSize: 14),
                            ),
                    ),
                  ),
                ],
              ],
            ),
            if (showCodeInput) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: '인증코드 6자리',
                        counterText: '',
                        prefixIcon: const Icon(Icons.pin_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 56,
                    child: FilledButton(
                      onPressed: verificationStatus == VerificationStatus.verifying
                          ? null
                          : _onVerifyCode,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: verificationStatus == VerificationStatus.verifying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('확인', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ],
            if (isVerified) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '이메일 인증이 완료되었습니다',
                    style: TextStyle(fontSize: 13, color: Colors.green),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: '비밀번호',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: '8자 이상, 대/소문자, 숫자, 특수문자 포함',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '비밀번호를 입력해주세요';
                }
                if (value.length < 8) {
                  return '비밀번호는 8자 이상이어야 합니다';
                }
                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                  return '대문자를 포함해주세요';
                }
                if (!RegExp(r'[a-z]').hasMatch(value)) {
                  return '소문자를 포함해주세요';
                }
                if (!RegExp(r'[0-9]').hasMatch(value)) {
                  return '숫자를 포함해주세요';
                }
                if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                  return '특수문자를 포함해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _onNext(),
              decoration: InputDecoration(
                labelText: '비밀번호 확인',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '비밀번호를 다시 입력해주세요';
                }
                if (value != _passwordController.text) {
                  return '비밀번호가 일치하지 않습니다';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: isVerified ? _onNext : null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                '다음',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
