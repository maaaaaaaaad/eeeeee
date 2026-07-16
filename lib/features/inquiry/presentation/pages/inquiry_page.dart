import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';
import 'package:mobile_owner/shared/widgets/app_bottom_inset.dart';
import 'package:mobile_owner/shared/widgets/app_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class InquiryPage extends StatelessWidget {
  const InquiryPage({super.key});

  static const String _email = 'zellomark123@gmail.com';
  static const String _instagramHandle = 'jellomark_nail';
  static const String _instagramUrl =
      'https://www.instagram.com/$_instagramHandle';

  Future<void> _openEmail(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri(
      scheme: 'mailto',
      path: _email,
      queryParameters: {'subject': '젤로마크 사장님 앱 문의'},
    );
    if (!await launchUrl(uri)) {
      await Clipboard.setData(const ClipboardData(text: _email));
      messenger.showSnackBar(
        const SnackBar(content: Text('메일 앱을 열 수 없어 이메일을 클립보드에 복사했어요.')),
      );
    }
  }

  Future<void> _openInstagram(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.parse(_instagramUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await Clipboard.setData(const ClipboardData(text: _instagramUrl));
      messenger.showSnackBar(
        const SnackBar(content: Text('인스타그램을 열 수 없어 링크를 클립보드에 복사했어요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text(
          '문의하기',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '궁금한 점이나 불편한 점이 있으신가요?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '아래 채널로 편하게 연락주세요.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            _InquiryTile(
              icon: Icons.email_outlined,
              label: '이메일',
              value: _email,
              onTap: () => _openEmail(context),
            ),
            const SizedBox(height: 12),
            _InquiryTile(
              icon: Icons.camera_alt_outlined,
              label: '인스타그램',
              value: '@$_instagramHandle',
              onTap: () => _openInstagram(context),
            ),
            const AppBottomInset(additional: 16),
          ],
        ),
      ),
    );
  }
}

class _InquiryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _InquiryTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.pastelPink, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}
