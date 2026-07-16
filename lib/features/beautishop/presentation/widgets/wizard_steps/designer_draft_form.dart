import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/core/network/api_error_handler.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/designer_draft.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/shop_image_picker.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/wizard_steps/description_step.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';
import 'package:mobile_owner/shared/widgets/app_bottom_sheet.dart';

class DesignerDraftForm extends ConsumerStatefulWidget {
  final DesignerDraft? initial;
  final void Function(DesignerDraft) onSave;

  const DesignerDraftForm({super.key, this.initial, required this.onSave});

  static Future<void> show({
    required BuildContext context,
    DesignerDraft? initial,
    required void Function(DesignerDraft) onSave,
  }) {
    return showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DesignerDraftForm(initial: initial, onSave: onSave),
    );
  }

  @override
  ConsumerState<DesignerDraftForm> createState() => _DesignerDraftFormState();
}

class _DesignerDraftFormState extends ConsumerState<DesignerDraftForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _nicknameController;
  late final TextEditingController _introController;
  late List<String> _photoUrls;
  bool _isUploading = false;

  static const int _nameMaxLength = 30;
  static const int _nicknameMaxLength = 30;
  static const int _introMaxLength = 500;
  static const int _maxPhotos = 5;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _nicknameController = TextEditingController(text: initial?.nickname ?? '');
    _introController = TextEditingController(text: initial?.intro ?? '');
    _photoUrls = List.of(initial?.photoUrls ?? const []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _introController.dispose();
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

  void _submit() {
    if (_isUploading) return;
    if (!_formKey.currentState!.validate()) return;

    final nickname = _nicknameController.text.trim();
    final intro = _introController.text.trim();

    widget.onSave(
      DesignerDraft(
        name: _nameController.text.trim(),
        nickname: nickname.isEmpty ? null : nickname,
        intro: intro.isEmpty ? null : intro,
        photoUrls: _photoUrls,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.initial == null ? '디자이너 추가' : '디자이너 수정',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              _buildNameField(),
              const SizedBox(height: 16),
              _buildNicknameField(),
              const SizedBox(height: 16),
              _buildIntroField(),
              const SizedBox(height: 16),
              _buildPhotosField(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isUploading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.pastelPink,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    _isUploading ? '이미지 업로드 중...' : '저장',
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
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      maxLength: _nameMaxLength,
      decoration: const InputDecoration(
        labelText: '이름 (필수)',
        hintText: '예: 김디자이너',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        final trimmed = (value ?? '').trim();
        if (trimmed.isEmpty) return '이름을 입력해주세요';
        if (trimmed.length < 2) return '이름은 2자 이상이어야 합니다';
        return null;
      },
    );
  }

  Widget _buildNicknameField() {
    return TextFormField(
      controller: _nicknameController,
      maxLength: _nicknameMaxLength,
      decoration: const InputDecoration(
        labelText: '닉네임 (선택)',
        hintText: '예: 젤리',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildIntroField() {
    return TextFormField(
      controller: _introController,
      maxLength: _introMaxLength,
      minLines: 3,
      maxLines: 6,
      decoration: const InputDecoration(
        labelText: '소개 (선택)',
        hintText: '경력, 스타일 등을 자유롭게 소개해주세요',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildPhotosField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '디자이너 사진 (선택, 최대 $_maxPhotos장)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        ShopImagePicker(
          initialUrls: _photoUrls,
          maxImages: _maxPhotos,
          onChanged: (urls) => setState(() => _photoUrls = urls),
          onUpload: _uploadImage,
          onUploadingChanged: (uploading) =>
              setState(() => _isUploading = uploading),
        ),
      ],
    );
  }
}
