import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/auth/presentation/providers/sign_up_provider.dart';
import 'package:mobile_owner/features/auth/presentation/widgets/sign_up_step1.dart';
import 'package:mobile_owner/features/auth/presentation/widgets/sign_up_step2.dart';
import 'package:mobile_owner/features/auth/presentation/widgets/sign_up_step3.dart';
import 'package:mobile_owner/features/auth/presentation/widgets/step_indicator.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextStep() {
    final notifier = ref.read(signUpNotifierProvider.notifier);
    notifier.nextStep();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPreviousStep() {
    final notifier = ref.read(signUpNotifierProvider.notifier);
    notifier.previousStep();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _onSubmit() async {
    await ref.read(signUpNotifierProvider.notifier).submit();
  }

  @override
  Widget build(BuildContext context) {
    final signUpState = ref.watch(signUpNotifierProvider);

    ref.listen(signUpNotifierProvider, (previous, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('회원가입이 완료되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      } else if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? '회원가입에 실패했습니다'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        leading: signUpState.currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _onPreviousStep,
              )
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              StepIndicator(
                currentStep: signUpState.currentStep,
                totalSteps: 3,
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    SignUpStep1(onNext: _onNextStep),
                    SignUpStep2(onNext: _onNextStep),
                    SignUpStep3(
                      onSubmit: _onSubmit,
                      isLoading: signUpState.isLoading,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
