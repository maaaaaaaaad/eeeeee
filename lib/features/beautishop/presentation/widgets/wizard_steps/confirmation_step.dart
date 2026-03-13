import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/shop_registration_wizard_provider.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/operating_hours_display.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class ConfirmationStep extends ConsumerWidget {
  const ConfirmationStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shopRegistrationWizardProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '등록 정보를 확인해주세요',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: '기본 정보',
            step: 0,
            ref: ref,
            children: [
              _buildInfoRow('샵 이름', state.shopName),
              _buildInfoRow('사업자등록번호', state.shopRegNum),
              _buildInfoRow('전화번호', state.shopPhoneNumber),
            ],
          ),
          const Divider(height: 32),
          _buildSection(
            title: '위치 정보',
            step: 1,
            ref: ref,
            children: [
              _buildInfoRow(
                '주소',
                _buildCombinedAddress(state),
              ),
            ],
          ),
          const Divider(height: 32),
          _buildSection(
            title: '영업 시간',
            step: 2,
            ref: ref,
            children: [
              OperatingHoursDisplay(operatingTime: state.operatingTime),
            ],
          ),
          const Divider(height: 32),
          _buildSection(
            title: '샵 설명',
            step: 3,
            ref: ref,
            children: [
              Text(
                state.shopDescription,
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              ),
              if (state.shopImages.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '이미지 ${state.shopImages.length}개',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          const Divider(height: 32),
          _buildSection(
            title: '시술 메뉴 (${state.treatmentDrafts.length}개)',
            step: 4,
            ref: ref,
            children: state.treatmentDrafts
                .map(
                  (draft) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            draft.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          '${_formatPrice(draft.price)}원 · ${draft.duration}분',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required int step,
    required WidgetRef ref,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => ref
                  .read(shopRegistrationWizardProvider.notifier)
                  .goToStep(step),
              child: const Text(
                '수정',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.accentPink,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildCombinedAddress(ShopRegistrationWizardState state) {
    final base = state.selectedLocation?.displayAddress ?? '';
    final detail = state.detailAddress.trim();
    if (detail.isEmpty) return base;
    return '$base $detail';
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
