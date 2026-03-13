import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/shop_registration_wizard_provider.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/shop_image_url_list.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class DescriptionStep extends ConsumerStatefulWidget {
  const DescriptionStep({super.key});

  @override
  ConsumerState<DescriptionStep> createState() => _DescriptionStepState();
}

class _DescriptionStepState extends ConsumerState<DescriptionStep> {
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(shopRegistrationWizardProvider);
    _descriptionController =
        TextEditingController(text: state.shopDescription);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = ref.watch(
      shopRegistrationWizardProvider.select((s) => s.shopImages),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '샵 설명을 입력해주세요',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '샵 설명은 필수입니다',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _descriptionController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: '샵 설명',
              hintText: '샵에 대한 소개를 작성해주세요',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (v) => ref
                .read(shopRegistrationWizardProvider.notifier)
                .updateShopDescription(v),
          ),
          const SizedBox(height: 24),
          const Text(
            '이미지 URL',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ShopImageUrlList(
            initialUrls: images,
            onChanged: (urls) => ref
                .read(shopRegistrationWizardProvider.notifier)
                .updateShopImages(urls),
          ),
        ],
      ),
    );
  }
}
