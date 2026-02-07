import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/update_shop_params.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/shop_edit_provider.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/operating_time_form.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/shop_image_url_list.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

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

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.shop.description ?? '');
    _operatingTime = Map.from(widget.shop.operatingTime);
    _imageUrls = List.from(widget.shop.images);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopEditNotifierProvider);

    ref.listen<ShopEditState>(shopEditNotifierProvider, (prev, next) {
      if (next.status == ShopEditStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('샵이 수정되었습니다')),
        );
        Navigator.pop(context, true);
      } else if (next.status == ShopEditStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? '수정에 실패했습니다')),
        );
      }
    });

    return Scaffold(
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
              '이미지 URL',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ShopImageUrlList(
              initialUrls: _imageUrls,
              onChanged: (urls) => _imageUrls = urls,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                    state.status == ShopEditStatus.loading ? null : _onSubmit,
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
            ),
            const SizedBox(height: 20),
          ],
        ),
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
    );

    ref.read(shopEditNotifierProvider.notifier).update(params);
  }
}
