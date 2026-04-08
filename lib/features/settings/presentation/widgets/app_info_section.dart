import 'package:flutter/material.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class AppInfoSection extends StatelessWidget {
  final String appVersion;

  const AppInfoSection({super.key, required this.appVersion});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            '앱 정보',
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
            side: BorderSide(color: AppColors.divider),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.description_outlined, color: AppColors.textSecondary),
                title: const Text('이용약관'),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('준비 중입니다')),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.textSecondary),
                title: const Text('개인정보처리방침'),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('준비 중입니다')),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline, color: AppColors.textSecondary),
                title: const Text('앱 버전'),
                trailing: Text(
                  appVersion,
                  style: const TextStyle(color: AppColors.textHint, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
