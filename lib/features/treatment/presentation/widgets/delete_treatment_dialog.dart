import 'package:flutter/material.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class DeleteTreatmentDialog extends StatelessWidget {
  final String treatmentName;

  const DeleteTreatmentDialog({super.key, required this.treatmentName});

  static Future<bool?> show(BuildContext context,
      {required String treatmentName}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => DeleteTreatmentDialog(treatmentName: treatmentName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        '시술 삭제',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      content: Text(
        '"$treatmentName"을(를) 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            '취소',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
          ),
          child: const Text(
            '삭제',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
