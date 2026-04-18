import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/auth/presentation/providers/forgot_password_provider.dart';
import 'package:mobile_owner/features/auth/presentation/providers/sign_up_provider.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _pageController = PageController();
  int _currentStep = 0;

  final _emailController = TextEditingController();
  final _emailCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _smsCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Timer? _emailTimer;
  Timer? _smsTimer;
  int _emailCooldown = 0;
  int _smsCooldown = 0;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _emailCodeController.dispose();
    _phoneController.dispose();
    _smsCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailTimer?.cancel();
    _smsTimer?.cancel();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _startEmailCooldown() {
    _emailCooldown = 60;
    _emailTimer?.cancel();
    _emailTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        _emailCooldown--;
        if (_emailCooldown <= 0) t.cancel();
      });
    });
  }

  void _startSmsCooldown() {
    _smsCooldown = 60;
    _smsTimer?.cancel();
    _smsTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        _smsCooldown--;
        if (_smsCooldown <= 0) t.cancel();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordNotifierProvider);

    ref.listen<ForgotPasswordState>(forgotPasswordNotifierProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
      if (next.resetStatus == ResetPasswordStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호가 변경되었습니다. 새 비밀번호로 로그인해주세요.')),
        );
        Navigator.pop(context);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '비밀번호 찾기',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            _buildStepIndicator(),
            const Divider(height: 1),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildEmailStep(state),
                  _buildSmsStep(state),
                  _buildPasswordStep(state),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(3, (i) {
          final labels = ['이메일 인증', '전화번호 인증', '새 비밀번호'];
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
              child: Column(
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= _currentStep
                          ? AppColors.pastelPink
                          : AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 11,
                      color: i <= _currentStep
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmailStep(ForgotPasswordState state) {
    final emailStatus = state.emailStatus;
    final showCode = emailStatus == VerificationStatus.codeSent ||
        emailStatus == VerificationStatus.verifying;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '가입한 이메일을\n입력해주세요',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '등록된 이메일로 인증코드를 보내드립니다',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: state.isEmailVerified,
                  decoration: InputDecoration(
                    labelText: '이메일',
                    prefixIcon: Icon(
                      state.isEmailVerified ? Icons.check_circle : Icons.email_outlined,
                      color: state.isEmailVerified ? Colors.green : null,
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              if (!state.isEmailVerified) ...[
                const SizedBox(width: 8),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: emailStatus == VerificationStatus.sending || _emailCooldown > 0
                        ? null
                        : () {
                            ref.read(forgotPasswordNotifierProvider.notifier)
                                .updateEmail(_emailController.text.trim());
                            ref.read(forgotPasswordNotifierProvider.notifier).sendEmailCode();
                            _startEmailCooldown();
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: emailStatus == VerificationStatus.sending
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_emailCooldown > 0 ? '${_emailCooldown}s' : showCode ? '재전송' : '인증', style: const TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ],
          ),
          if (showCode) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailCodeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: '인증코드 6자리',
                      counterText: '',
                      prefixIcon: const Icon(Icons.pin_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: emailStatus == VerificationStatus.verifying
                        ? null
                        : () => ref.read(forgotPasswordNotifierProvider.notifier)
                            .verifyEmailCode(_emailCodeController.text.trim()),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: emailStatus == VerificationStatus.verifying
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('확인', style: TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ),
          ],
          if (state.isEmailVerified) ...[
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 4),
                Text('이메일 인증이 완료되었습니다', style: TextStyle(fontSize: 13, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => _goToStep(1),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
              ),
              child: const Text('다음', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSmsStep(ForgotPasswordState state) {
    final smsStatus = state.smsStatus;
    final showCode = smsStatus == VerificationStatus.codeSent ||
        smsStatus == VerificationStatus.verifying;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '가입한 전화번호를\n입력해주세요',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'SMS로 인증코드를 보내드립니다',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  readOnly: state.isSmsVerified,
                  decoration: InputDecoration(
                    labelText: '전화번호',
                    hintText: '01012345678',
                    prefixIcon: Icon(
                      state.isSmsVerified ? Icons.check_circle : Icons.phone_outlined,
                      color: state.isSmsVerified ? Colors.green : null,
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              if (!state.isSmsVerified) ...[
                const SizedBox(width: 8),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: smsStatus == VerificationStatus.sending || _smsCooldown > 0
                        ? null
                        : () {
                            ref.read(forgotPasswordNotifierProvider.notifier)
                                .updatePhoneNumber(_phoneController.text.trim());
                            ref.read(forgotPasswordNotifierProvider.notifier).sendSmsCode();
                            _startSmsCooldown();
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: smsStatus == VerificationStatus.sending
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_smsCooldown > 0 ? '${_smsCooldown}s' : showCode ? '재전송' : '인증', style: const TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ],
          ),
          if (showCode) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _smsCodeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: '인증코드 6자리',
                      counterText: '',
                      prefixIcon: const Icon(Icons.pin_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: smsStatus == VerificationStatus.verifying
                        ? null
                        : () => ref.read(forgotPasswordNotifierProvider.notifier)
                            .verifySmsCode(_smsCodeController.text.trim()),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: smsStatus == VerificationStatus.verifying
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('확인', style: TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ),
          ],
          if (state.isSmsVerified) ...[
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 4),
                Text('전화번호 인증이 완료되었습니다', style: TextStyle(fontSize: 13, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => _goToStep(2),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
              ),
              child: const Text('다음', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPasswordStep(ForgotPasswordState state) {
    final isLoading = state.resetStatus == ResetPasswordStatus.loading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '새 비밀번호를\n설정해주세요',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: '새 비밀번호',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              helperText: '8자 이상, 대/소문자, 숫자, 특수문자 포함',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            decoration: InputDecoration(
              labelText: '새 비밀번호 확인',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: isLoading
                ? null
                : () {
                    final pw = _passwordController.text;
                    final confirm = _confirmPasswordController.text;

                    if (pw.length < 8) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('비밀번호는 8자 이상이어야 합니다')),
                      );
                      return;
                    }
                    if (pw != confirm) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('비밀번호가 일치하지 않습니다')),
                      );
                      return;
                    }

                    ref.read(forgotPasswordNotifierProvider.notifier).resetPassword(pw);
                  },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.primary,
            ),
            child: isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('비밀번호 변경', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
