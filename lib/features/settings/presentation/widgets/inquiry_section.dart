import 'package:flutter/material.dart';
import 'package:mobile_owner/features/inquiry/presentation/pages/inquiry_page.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class InquirySection extends StatelessWidget {
  const InquirySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            '고객 지원',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.divider),
          ),
          child: ListTile(
            leading: const Icon(
              Icons.help_outline,
              color: AppColors.textSecondary,
            ),
            title: const Text('문의하기'),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textHint,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const InquiryPage()),
              );
            },
          ),
        ),
      ],
    );
  }
}
