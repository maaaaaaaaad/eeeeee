import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/update_shop_params.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/shop_edit_provider.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/operating_time_form.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class ScheduleManagementPage extends ConsumerStatefulWidget {
  final BeautyShop shop;

  const ScheduleManagementPage({super.key, required this.shop});

  @override
  ConsumerState<ScheduleManagementPage> createState() =>
      _ScheduleManagementPageState();
}

class _ScheduleManagementPageState
    extends ConsumerState<ScheduleManagementPage> {
  late Map<String, String> _operatingTime;

  @override
  void initState() {
    super.initState();
    _operatingTime = Map.of(widget.shop.operatingTime);
  }

  Future<void> _onSave() async {
    final params = UpdateShopParams(
      shopId: widget.shop.id,
      operatingTime: _operatingTime,
      shopDescription: widget.shop.description,
      shopImages: widget.shop.images,
    );

    await ref.read(shopEditNotifierProvider.notifier).update(params);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopEditNotifierProvider);

    ref.listen<ShopEditState>(shopEditNotifierProvider, (prev, next) {
      if (next.status == ShopEditStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('스케줄이 저장되었습니다')),
        );
        Navigator.pop(context, true);
      }
      if (next.status == ShopEditStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '스케줄 관리',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '요일별 영업시간',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            OperatingTimeForm(
              initialValue: widget.shop.operatingTime,
              onChanged: (value) => _operatingTime = value,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: state.status == ShopEditStatus.loading
                    ? null
                    : _onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.pastelPink,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: state.status == ShopEditStatus.loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        '저장',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
