import 'package:flutter/material.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class RejectReservationDialog extends StatefulWidget {
  const RejectReservationDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const RejectReservationDialog(),
    );
  }

  @override
  State<RejectReservationDialog> createState() =>
      _RejectReservationDialogState();
}

class _RejectReservationDialogState extends State<RejectReservationDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        '예약 거절',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: '거절 사유를 입력해주세요',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
        onChanged: (_) => setState(() {}),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            '취소',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: _controller.text.trim().isEmpty
              ? null
              : () => Navigator.pop(context, _controller.text.trim()),
          child: Text(
            '거절하기',
            style: TextStyle(
              color: _controller.text.trim().isEmpty
                  ? AppColors.disabled
                  : AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
