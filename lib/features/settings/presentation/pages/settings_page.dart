import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mobile_owner/features/auth/presentation/pages/login_page.dart';
import 'package:mobile_owner/features/auth/presentation/pages/withdrawal_page.dart';
import 'package:mobile_owner/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile_owner/features/home/presentation/providers/home_provider.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';
import 'package:mobile_owner/features/settings/presentation/widgets/account_section.dart';
import 'package:mobile_owner/features/settings/presentation/widgets/app_info_section.dart';
import 'package:mobile_owner/features/settings/presentation/widgets/notification_section.dart';
import 'package:mobile_owner/features/settings/presentation/widgets/profile_section.dart';

final _logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeNotifierProvider);
    final owner = homeState.owner;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '설정',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          if (owner != null) ProfileSection(owner: owner),
          const SizedBox(height: 24),
          AccountSection(onLogout: () => _handleLogout(context, ref)),
          const SizedBox(height: 16),
          const NotificationSection(),
          const SizedBox(height: 16),
          const AppInfoSection(appVersion: _appVersion),
          const SizedBox(height: 32),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WithdrawalPage()),
                );
              },
              child: const Text(
                '회원 탈퇴',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    ref.read(_logoutUseCaseProvider).call(NoParams());
    ref.read(authNotifierProvider.notifier).logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
}
