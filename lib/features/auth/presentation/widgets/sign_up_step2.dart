import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/auth/presentation/providers/sign_up_provider.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';
import 'package:mobile_owner/shared/utils/input_formatters.dart';

class SignUpStep2 extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const SignUpStep2({super.key, required this.onNext});

  @override
  ConsumerState<SignUpStep2> createState() => _SignUpStep2State();
}

class _SignUpStep2State extends ConsumerState<SignUpStep2> {
  final _formKey = GlobalKey<FormState>();
  final _businessNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = ref.read(signUpNotifierProvider);
    _businessNumberController.text = state.businessNumber;
  }

  @override
  void dispose() {
    _businessNumberController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_formKey.currentState?.validate() ?? false) {
      final notifier = ref.read(signUpNotifierProvider.notifier);
      notifier.updateBusinessNumber(_businessNumberController.text.trim());
      widget.onNext();
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
              '사업자등록번호를\n입력해주세요',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '사업자등록번호로 본인 확인을 진행합니다',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _businessNumberController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _onNext(),
              decoration: InputDecoration(
                labelText: '사업자등록번호',
                hintText: '000-00-00000 또는 0000000000',
                prefixIcon: const Icon(Icons.business_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: '하이픈(-) 포함 또는 숫자만 입력 가능',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '사업자등록번호를 입력해주세요';
                }
                if (!BusinessNumberFormatter.isValid(value)) {
                  return '올바른 사업자등록번호 형식이 아닙니다';
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
                      '추후 국세청 API를 통해 사업자 진위 확인이 진행될 예정입니다.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _onNext,
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
