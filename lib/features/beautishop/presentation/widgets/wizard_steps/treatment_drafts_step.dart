import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/treatment_draft.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/shop_registration_wizard_provider.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/wizard_steps/treatment_draft_form.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class TreatmentDraftsStep extends ConsumerWidget {
  const TreatmentDraftsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drafts = ref.watch(
      shopRegistrationWizardProvider.select((s) => s.treatmentDrafts),
    );

    return Padding(
      padding: const EdgeInsets.all(20),
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
          Expanded(
            child: drafts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                  )
                : ListView.separated(
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
        ],
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
