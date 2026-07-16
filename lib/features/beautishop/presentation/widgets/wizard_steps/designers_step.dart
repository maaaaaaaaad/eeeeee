import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/designer_draft.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/shop_registration_wizard_provider.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/wizard_steps/designer_draft_form.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class DesignersStep extends ConsumerWidget {
  const DesignersStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drafts = ref.watch(
      shopRegistrationWizardProvider.select((s) => s.designerDrafts),
    );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '디자이너를 등록해주세요',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '선택 사항입니다. 나중에 샵 편집에서 추가/수정할 수 있어요.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            if (drafts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 48,
                        color: AppColors.disabled,
                      ),
                      SizedBox(height: 12),
                      Text(
                        '등록된 디자이너가 없습니다',
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
                  return _DesignerDraftCard(
                    draft: draft,
                    onEdit: () => _editDraft(context, ref, index, draft),
                    onDelete: () => ref
                        .read(shopRegistrationWizardProvider.notifier)
                        .removeDesignerDraft(index),
                  );
                },
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _addDraft(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('디자이너 추가'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.pastelPink),
                  foregroundColor: AppColors.accentPink,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _addDraft(BuildContext context, WidgetRef ref) {
    DesignerDraftForm.show(
      context: context,
      onSave: (draft) => ref
          .read(shopRegistrationWizardProvider.notifier)
          .addDesignerDraft(draft),
    );
  }

  void _editDraft(
    BuildContext context,
    WidgetRef ref,
    int index,
    DesignerDraft current,
  ) {
    DesignerDraftForm.show(
      context: context,
      initial: current,
      onSave: (draft) => ref
          .read(shopRegistrationWizardProvider.notifier)
          .updateDesignerDraft(index, draft),
    );
  }
}

class _DesignerDraftCard extends StatelessWidget {
  final DesignerDraft draft;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DesignerDraftCard({
    required this.draft,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = <String>[
      if (draft.nickname != null && draft.nickname!.isNotEmpty)
        '@${draft.nickname!}',
      if (draft.photoUrls.isNotEmpty) '사진 ${draft.photoUrls.length}장',
    ].join(' · ');

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
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (draft.intro != null && draft.intro!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        draft.intro!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
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
}
