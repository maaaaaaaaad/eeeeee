import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/core/network/api_error_handler.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/treatment_draft.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/shop_registration_wizard_provider.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/shop_image_picker.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/wizard_steps/description_step.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/wizard_steps/treatment_draft_form.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class TreatmentDraftsStep extends ConsumerStatefulWidget {
  const TreatmentDraftsStep({super.key});

  @override
  ConsumerState<TreatmentDraftsStep> createState() =>
      _TreatmentDraftsStepState();
}

class _TreatmentDraftsStepState extends ConsumerState<TreatmentDraftsStep> {
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
    final drafts = ref.watch(
      shopRegistrationWizardProvider.select((s) => s.treatmentDrafts),
    );
    final menuImages = ref.watch(
      shopRegistrationWizardProvider.select((s) => s.menuImages),
    );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '시술 메뉴를 등록해주세요',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '최소 1개 이상의 시술을 등록해야 합니다',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            if (drafts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.content_cut,
                        size: 48,
                        color: AppColors.disabled,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '등록된 시술이 없습니다',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: drafts.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final draft = drafts[index];
                  return _TreatmentDraftCard(
                    draft: draft,
                    onEdit: () => _editDraft(context, ref, index, draft),
                    onDelete: () => ref
                        .read(shopRegistrationWizardProvider.notifier)
                        .removeTreatmentDraft(index),
                  );
                },
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _addDraft(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('시술 추가'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.pastelPink),
                  foregroundColor: AppColors.accentPink,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  '시술 메뉴판 사진',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '선택',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '종이 메뉴판 사진을 업로드하면 손님이 한눈에 볼 수 있어요 (최대 3장)',
              style: TextStyle(fontSize: 12, color: AppColors.textHint),
            ),
            const SizedBox(height: 12),
            ShopImagePicker(
              initialUrls: menuImages,
              maxImages: 3,
              onChanged: (urls) => ref
                  .read(shopRegistrationWizardProvider.notifier)
                  .updateMenuImages(urls),
              onUpload: _uploadImage,
              onUploadingChanged: (uploading) => ref
                  .read(shopRegistrationWizardProvider.notifier)
                  .setImageUploading(uploading),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _addDraft(BuildContext context, WidgetRef ref) {
    TreatmentDraftForm.show(
      context: context,
      onSave: (draft) => ref
          .read(shopRegistrationWizardProvider.notifier)
          .addTreatmentDraft(draft),
    );
  }

  void _editDraft(
    BuildContext context,
    WidgetRef ref,
    int index,
    TreatmentDraft current,
  ) {
    TreatmentDraftForm.show(
      context: context,
      initial: current,
      onSave: (draft) => ref
          .read(shopRegistrationWizardProvider.notifier)
          .updateTreatmentDraft(index, draft),
    );
  }
}

class _TreatmentDraftCard extends StatelessWidget {
  final TreatmentDraft draft;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TreatmentDraftCard({
    required this.draft,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      draft.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatPrice(draft.price)}원 · ${draft.duration}분',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: AppColors.error,
                iconSize: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
