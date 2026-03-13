import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/shop_registration_wizard_provider.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/wizard_steps/basic_info_step.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/wizard_steps/confirmation_step.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/wizard_steps/description_step.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/wizard_steps/location_step.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/wizard_steps/operating_time_step.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/wizard_steps/step_indicator.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/wizard_steps/treatment_drafts_step.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class ShopRegistrationWizardPage extends ConsumerStatefulWidget {
  const ShopRegistrationWizardPage({super.key});

  @override
  ConsumerState<ShopRegistrationWizardPage> createState() =>
      _ShopRegistrationWizardPageState();
}

class _ShopRegistrationWizardPageState
    extends ConsumerState<ShopRegistrationWizardPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopRegistrationWizardProvider);

    ref.listen<ShopRegistrationWizardState>(
      shopRegistrationWizardProvider,
      (prev, next) {
        if (prev?.currentStep != next.currentStep) {
          _pageController.animateToPage(
            next.currentStep,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }

        if (next.submitStatus == SubmitStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('샵이 등록되었습니다')),
          );
          Navigator.pop(context, true);
        } else if (next.submitStatus == SubmitStatus.partialSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('샵은 등록되었으나 일부 시술 등록에 실패했습니다'),
            ),
          );
          Navigator.pop(context, true);
        } else if (next.submitStatus == SubmitStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.errorMessage ?? '등록에 실패했습니다')),
          );
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '샵 등록',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            StepIndicator(
              currentStep: state.currentStep,
              totalSteps: ShopRegistrationWizardNotifier.totalSteps,
            ),
            const Divider(height: 1),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  BasicInfoStep(),
                  LocationStep(),
                  OperatingTimeStep(),
                  DescriptionStep(),
                  TreatmentDraftsStep(),
                  ConfirmationStep(),
                ],
              ),
            ),
            _buildBottomBar(state),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(ShopRegistrationWizardState state) {
    final isFirstStep = state.currentStep == 0;
    final isLastStep =
        state.currentStep == ShopRegistrationWizardNotifier.totalSteps - 1;
    final isLoading = state.submitStatus == SubmitStatus.loading;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          if (!isFirstStep)
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : _onPrevious,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.divider),
                ),
                child: const Text(
                  '이전',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          if (!isFirstStep) const SizedBox(width: 12),
          Expanded(
            flex: isFirstStep ? 1 : 1,
            child: FilledButton(
              onPressed: isLoading ? null : (isLastStep ? _onSubmit : _onNext),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.pastelPink,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isLastStep ? '등록하기' : '다음',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _onPrevious() {
    ref.read(shopRegistrationWizardProvider.notifier).previousStep();
  }

  void _onNext() {
    final notifier = ref.read(shopRegistrationWizardProvider.notifier);
    final success = notifier.nextStep();
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('입력 정보를 확인해주세요')),
      );
    }
  }

  void _onSubmit() {
    ref.read(shopRegistrationWizardProvider.notifier).submit();
  }
}
