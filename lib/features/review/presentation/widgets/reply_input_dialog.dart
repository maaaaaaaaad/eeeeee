import 'package:flutter/material.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class ReplyInputDialog extends StatefulWidget {
  final String? initialContent;

  const ReplyInputDialog({
    super.key,
    this.initialContent,
  });

  @override
  State<ReplyInputDialog> createState() => _ReplyInputDialogState();
}

class _ReplyInputDialogState extends State<ReplyInputDialog> {
  late final TextEditingController _controller;
  static const _maxLength = 500;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _controller.text.trim().isNotEmpty &&
      _controller.text.trim().length <= _maxLength;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.initialContent != null ? '답글 수정' : '답글 작성',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLength: _maxLength,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '답글을 입력해주세요',
                hintStyle: const TextStyle(color: AppColors.textHint),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.pastelPink),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    '취소',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _isValid
                      ? () => Navigator.pop(context, _controller.text.trim())
                      : null,
                  child: Text(
                    widget.initialContent != null ? '수정' : '등록',
                    style: TextStyle(
                      color: _isValid
                          ? AppColors.pastelPink
                          : AppColors.textHint,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
