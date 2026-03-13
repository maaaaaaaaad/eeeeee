import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/shop_registration_wizard_provider.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';
import 'package:mobile_owner/shared/utils/validators.dart';

class BasicInfoStep extends ConsumerStatefulWidget {
  const BasicInfoStep({super.key});

  @override
  ConsumerState<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends ConsumerState<BasicInfoStep> {
  late final TextEditingController _nameController;
  late final TextEditingController _regNumController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(shopRegistrationWizardProvider);
    _nameController = TextEditingController(text: state.shopName);
    _regNumController = TextEditingController(text: state.shopRegNum);
    _phoneController = TextEditingController(text: state.shopPhoneNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regNumController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final regNumStatus =
        ref.watch(shopRegistrationWizardProvider.select((s) => s.regNumCheckStatus));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '기본 정보를 입력해주세요',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '샵 이름',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (v) =>
                ref.read(shopRegistrationWizardProvider.notifier).updateShopName(v),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) => ShopNameValidator.validate(v ?? ''),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _regNumController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '사업자등록번호',
                    border: const OutlineInputBorder(),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    suffixIcon: _buildRegNumStatusIcon(regNumStatus),
                  ),
                  onChanged: (v) => ref
                      .read(shopRegistrationWizardProvider.notifier)
                      .updateShopRegNum(v),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (v) => BusinessNumberValidator.validate(v ?? ''),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: regNumStatus == RegNumCheckStatus.checking
                      ? null
                      : _onCheckRegNum,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.pastelPink,
                  ),
                  child: regNumStatus == RegNumCheckStatus.checking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '중복확인',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                ),
              ),
            ],
          ),
          if (regNumStatus == RegNumCheckStatus.available)
            const Padding(
              padding: EdgeInsets.only(top: 4, left: 4),
              child: Text(
                '사용 가능한 사업자등록번호입니다',
                style: TextStyle(fontSize: 12, color: Colors.green),
              ),
            ),
          if (regNumStatus == RegNumCheckStatus.duplicate)
            const Padding(
              padding: EdgeInsets.only(top: 4, left: 4),
              child: Text(
                '이미 등록된 사업자등록번호입니다',
                style: TextStyle(fontSize: 12, color: AppColors.error),
              ),
            ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: '전화번호',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (v) => ref
                .read(shopRegistrationWizardProvider.notifier)
                .updateShopPhoneNumber(v),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) => PhoneNumberValidator.validate(v ?? ''),
          ),
        ],
      ),
    );
  }

  Widget? _buildRegNumStatusIcon(RegNumCheckStatus status) {
    switch (status) {
      case RegNumCheckStatus.available:
        return const Icon(Icons.check_circle, color: Colors.green, size: 20);
      case RegNumCheckStatus.duplicate:
        return const Icon(Icons.cancel, color: AppColors.error, size: 20);
      default:
        return null;
    }
  }

  void _onCheckRegNum() {
    if (BusinessNumberValidator.validate(_regNumController.text) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('올바른 사업자등록번호를 입력해주세요')),
      );
      return;
    }
    ref.read(shopRegistrationWizardProvider.notifier).checkRegNumAvailability();
  }
}
