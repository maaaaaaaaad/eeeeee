import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/auth/presentation/providers/sign_up_provider.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';
import 'package:mobile_owner/shared/utils/input_formatters.dart';

class SignUpStep3 extends ConsumerStatefulWidget {
  final Future<void> Function() onSubmit;
  final bool isLoading;

  const SignUpStep3({
    super.key,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  ConsumerState<SignUpStep3> createState() => _SignUpStep3State();
}

class _SignUpStep3State extends ConsumerState<SignUpStep3> {
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();
  final _nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = ref.read(signUpNotifierProvider);
    _phoneNumberController.text = state.phoneNumber;
    _nicknameController.text = state.nickname;
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final notifier = ref.read(signUpNotifierProvider.notifier);
      notifier.updatePhoneNumber(_phoneNumberController.text.trim());
      notifier.updateNickname(_nicknameController.text.trim());
      widget.onSubmit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '휴대폰 번호와 닉네임을\n입력해주세요',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '마지막 단계입니다',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: '휴대폰 번호',
                hintText: '010-0000-0000 또는 01000000000',
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: '하이픈(-) 포함 또는 숫자만 입력 가능',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '휴대폰 번호를 입력해주세요';
                }
                if (!PhoneNumberFormatter.isValid(value)) {
                  return '올바른 휴대폰 번호 형식이 아닙니다';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '추후 SMS 인증이 추가될 예정입니다.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nicknameController,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _onSubmit(),
              decoration: InputDecoration(
                labelText: '닉네임',
                hintText: '앱에서 사용할 닉네임',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '닉네임을 입력해주세요';
                }
                if (value.length < 2) {
                  return '닉네임은 2자 이상이어야 합니다';
                }
                if (value.length > 20) {
                  return '닉네임은 20자 이하여야 합니다';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: widget.isLoading ? null : _onSubmit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      '가입 완료',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
