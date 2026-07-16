import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/core/network/api_error_handler.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/designer_draft.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/update_shop_params.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/shop_edit_provider.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/operating_time_form.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/shop_image_picker.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/wizard_steps/description_step.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/wizard_steps/designer_draft_form.dart';
import 'package:mobile_owner/features/designer/domain/entities/create_designer_params.dart';
import 'package:mobile_owner/features/designer/domain/entities/designer.dart';
import 'package:mobile_owner/features/designer/domain/entities/update_designer_params.dart';
import 'package:mobile_owner/features/designer/presentation/providers/designer_list_provider.dart';
import 'package:mobile_owner/features/designer/presentation/widgets/designer_card.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';
import 'package:mobile_owner/shared/widgets/app_bottom_action_bar.dart';
import 'package:mobile_owner/shared/widgets/app_bottom_sheet.dart';
import 'package:mobile_owner/shared/widgets/app_scaffold.dart';

class ShopEditPage extends ConsumerStatefulWidget {
  final BeautyShop shop;

  const ShopEditPage({super.key, required this.shop});

  @override
  ConsumerState<ShopEditPage> createState() => _ShopEditPageState();
}

class _ShopEditPageState extends ConsumerState<ShopEditPage> {
  late final TextEditingController _descriptionController;
  late Map<String, String> _operatingTime;
  late List<String> _imageUrls;
  late List<String> _menuImageUrls;
  bool _isShopImagesUploading = false;
  bool _isMenuImagesUploading = false;

  bool get _isUploading => _isShopImagesUploading || _isMenuImagesUploading;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.shop.description ?? '',
    );
    _operatingTime = Map.from(widget.shop.operatingTime);
    _imageUrls = List.from(widget.shop.images);
    _menuImageUrls = List.from(widget.shop.menuImages);
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
    final state = ref.watch(shopEditNotifierProvider);

    ref.listen<ShopEditState>(shopEditNotifierProvider, (prev, next) {
      if (next.status == ShopEditStatus.success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('샵이 수정되었습니다')));
        Navigator.pop(context, true);
      } else if (next.status == ShopEditStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? '수정에 실패했습니다')),
        );
      }
    });

    return AppScaffold(
      appBar: AppBar(
        title: const Text(
          '샵 수정',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              '영업 시간',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            OperatingTimeForm(
              initialValue: _operatingTime,
              onChanged: (value) => _operatingTime = value,
            ),
            const SizedBox(height: 24),
            const Text(
              '샵 설명',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: '샵 소개를 입력해주세요',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '매장 사진',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ShopImagePicker(
              initialUrls: _imageUrls,
              onChanged: (urls) => _imageUrls = urls,
              onUpload: _uploadImage,
              onUploadingChanged: (uploading) =>
                  setState(() => _isShopImagesUploading = uploading),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  '시술 메뉴판 사진',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '선택',
                    style: TextStyle(fontSize: 11, color: AppColors.textHint),
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
              initialUrls: _menuImageUrls,
              maxImages: 3,
              onChanged: (urls) => _menuImageUrls = urls,
              onUpload: _uploadImage,
              onUploadingChanged: (uploading) =>
                  setState(() => _isMenuImagesUploading = uploading),
            ),
            const SizedBox(height: 24),
            _buildDesignerSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomAction: AppBottomActionBar(
        backgroundColor: Colors.white,
        children: [
          FilledButton(
            onPressed: state.status == ShopEditStatus.loading || _isUploading
                ? null
                : _onSubmit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.pastelPink,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: state.status == ShopEditStatus.loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    '수정하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _onSubmit() {
    final params = UpdateShopParams(
      shopId: widget.shop.id,
      operatingTime: _operatingTime,
      shopDescription: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      shopImages: _imageUrls,
      menuImages: _menuImageUrls,
    );

    ref.read(shopEditNotifierProvider.notifier).update(params);
  }

  Widget _buildDesignerSection() {
    final designerState =
        ref.watch(designerListNotifierProvider(widget.shop.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                '디자이너 관리',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _onAddDesigner,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('추가'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentPink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildDesignerBody(designerState),
      ],
    );
  }

  Widget _buildDesignerBody(DesignerListState state) {
    switch (state.status) {
      case DesignerListStatus.initial:
      case DesignerListStatus.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.pastelPink),
          ),
        );
      case DesignerListStatus.error:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Column(
              children: [
                Text(
                  state.errorMessage ?? '디자이너 목록을 불러올 수 없습니다',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref
                      .read(designerListNotifierProvider(widget.shop.id)
                          .notifier)
                      .refresh(),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        );
      case DesignerListStatus.loaded:
        if (state.designers.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                '등록된 디자이너가 없습니다',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.designers.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final designer = state.designers[index];
            return DesignerCard(
              designer: designer,
              onEdit: () => _onEditDesigner(designer),
              onDelete: () => _onDeleteDesigner(designer),
            );
          },
        );
    }
  }

  void _onAddDesigner() {
    DesignerDraftForm.show(
      context: context,
      onSave: (draft) async {
        final params = CreateDesignerParams(
          shopId: widget.shop.id,
          name: draft.name,
          nickname: draft.nickname,
          intro: draft.intro,
          photoUrls: draft.photoUrls,
        );
        final error = await ref
            .read(designerListNotifierProvider(widget.shop.id).notifier)
            .createDesigner(params);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? '디자이너가 추가되었습니다')),
        );
      },
    );
  }

  void _onEditDesigner(Designer designer) {
    DesignerDraftForm.show(
      context: context,
      initial: DesignerDraft(
        name: designer.name,
        nickname: designer.nickname,
        intro: designer.intro,
        photoUrls: designer.photoUrls,
      ),
      onSave: (draft) async {
        final params = UpdateDesignerParams(
          designerId: designer.id,
          shopId: widget.shop.id,
          name: draft.name,
          nickname: draft.nickname,
          intro: draft.intro,
          photoUrls: draft.photoUrls,
        );
        final error = await ref
            .read(designerListNotifierProvider(widget.shop.id).notifier)
            .updateDesigner(params);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? '디자이너 정보가 수정되었습니다')),
        );
      },
    );
  }

  Future<void> _onDeleteDesigner(Designer designer) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: '디자이너 삭제',
      message: '${designer.name} 님을 삭제하시겠습니까?',
      confirmLabel: '삭제',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;

    final error = await ref
        .read(designerListNotifierProvider(widget.shop.id).notifier)
        .deleteDesigner(designer.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? '디자이너가 삭제되었습니다')),
    );
  }
}
