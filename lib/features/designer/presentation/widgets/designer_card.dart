import 'package:flutter/material.dart';
import 'package:mobile_owner/features/designer/domain/entities/designer.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class DesignerCard extends StatelessWidget {
  final Designer designer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DesignerCard({
    super.key,
    required this.designer,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[
      if (designer.nickname != null && designer.nickname!.isNotEmpty)
        '@${designer.nickname!}',
      if (designer.photoUrls.isNotEmpty) '사진 ${designer.photoUrls.length}장',
    ];
    final subtitle = subtitleParts.join(' · ');

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
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      designer.name,
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
                    if (designer.intro != null &&
                        designer.intro!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        designer.intro!,
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

  Widget _buildAvatar() {
    if (designer.photoUrls.isEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.divider,
        child: const Icon(
          Icons.person,
          color: AppColors.textHint,
          size: 24,
        ),
      );
    }
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.divider,
      backgroundImage: NetworkImage(designer.photoUrls.first),
    );
  }
}
