import 'package:flutter/material.dart';
import 'package:mobile_owner/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';
import 'package:mobile_owner/shared/widgets/app_bottom_sheet.dart';

class AccountSection extends StatelessWidget {
  final VoidCallback onLogout;

  const AccountSection({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            '계정',
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
                leading: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                title: const Text('비밀번호 변경'),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordPage(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text('로그아웃', style: TextStyle(color: AppColors.error)),
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: '로그아웃',
      message: '정말 로그아웃 하시겠습니까?',
      confirmLabel: '로그아웃',
      isDestructive: true,
    );
    if (confirmed) {
      onLogout();
    }
  }
}
