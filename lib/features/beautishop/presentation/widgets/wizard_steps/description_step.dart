import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/core/network/api_error_handler.dart';
import 'package:mobile_owner/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile_owner/features/beautishop/data/datasources/image_remote_datasource.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/shop_registration_wizard_provider.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/shop_image_picker.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

final imageRemoteDataSourceProvider = Provider<ImageRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ImageRemoteDataSourceImpl(apiClient: apiClient);
});

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

  Future<String> _uploadImage(File file) async {
    try {
      final datasource = ref.read(imageRemoteDataSourceProvider);
      return await datasource.uploadImage(file);
    } on DioException catch (e) {
      final failure = ApiErrorHandler.fromDioException(
        e,
        fallback: '이미지 업로드에 실패했습니다',
      );
      throw Exception(failure.message);
    }
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
            '매장 사진',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ShopImagePicker(
            initialUrls: images,
            onChanged: (urls) => ref
                .read(shopRegistrationWizardProvider.notifier)
                .updateShopImages(urls),
            onUpload: _uploadImage,
          ),
        ],
      ),
    );
  }
}
