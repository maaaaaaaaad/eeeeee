import 'package:flutter/material.dart';
import 'package:mobile_owner/features/legal/data/legal_texts.dart';
import 'package:mobile_owner/features/legal/presentation/pages/legal_text_page.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class LegalSection extends StatelessWidget {
  const LegalSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            '약관 및 정책',
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
              _item(
                context: context,
                icon: Icons.description_outlined,
                title: '이용약관',
                body: LegalTexts.termsOfService,
              ),
              const Divider(height: 1),
              _item(
                context: context,
                icon: Icons.privacy_tip_outlined,
                title: '개인정보처리방침',
                body: LegalTexts.privacyPolicy,
              ),
              const Divider(height: 1),
              _item(
                context: context,
                icon: Icons.location_on_outlined,
                title: '위치정보 이용약관',
                body: LegalTexts.locationTerms,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _item({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String body,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LegalTextPage(title: title, body: body),
          ),
        );
      },
    );
  }
}
