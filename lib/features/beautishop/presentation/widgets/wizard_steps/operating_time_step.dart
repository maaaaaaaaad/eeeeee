import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/shop_registration_wizard_provider.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/operating_time_form.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class OperatingTimeStep extends ConsumerWidget {
  const OperatingTimeStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final operatingTime = ref.watch(
      shopRegistrationWizardProvider.select((s) => s.operatingTime),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '영업 시간을 설정해주세요',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          OperatingTimeForm(
            initialValue: operatingTime,
            onChanged: (value) => ref
                .read(shopRegistrationWizardProvider.notifier)
                .updateOperatingTime(value),
          ),
        ],
      ),
    );
  }
}
