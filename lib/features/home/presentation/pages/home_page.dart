import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/beautishop/presentation/pages/shop_registration_page.dart';
import 'package:mobile_owner/features/home/presentation/providers/home_provider.dart';
import 'package:mobile_owner/features/home/presentation/widgets/home_tab.dart';
import 'package:mobile_owner/features/home/presentation/widgets/my_shop_tab.dart';
import 'package:mobile_owner/features/notification/presentation/providers/notification_provider.dart';
import 'package:mobile_owner/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:mobile_owner/features/onboarding/presentation/widgets/onboarding_bottom_sheet.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;
  bool _onboardingChecked = false;

  static const _tabs = [
    HomeTab(),
    MyShopTab(),
    _SettingsPlaceholder(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotifications();
    });
  }

  void _initializeNotifications() {
    ref.read(reservationRefreshCallbackProvider.notifier).state = () {
      ref.read(homeNotifierProvider.notifier).refresh();
    };
    ref.read(localNotificationServiceProvider).initialize();
    ref.read(notificationInitProvider);
  }

  @override
  Widget build(BuildContext context) {
    _checkOnboarding();

    return Scaffold(
      body: SafeArea(child: _tabs[_currentIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.lightPink,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.darkPink),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.store_outlined),
            selectedIcon: Icon(Icons.store, color: AppColors.darkPink),
            label: '내 샵',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: AppColors.darkPink),
            label: '설정',
          ),
        ],
      ),
    );
  }

  void _checkOnboarding() {
    if (_onboardingChecked) return;

    final homeState = ref.watch(homeNotifierProvider);
    if (homeState.status != HomeStatus.loaded) return;

    _onboardingChecked = true;

    final shopsEmpty = !homeState.hasShops;
    final shouldShow = ref.read(shouldShowOnboardingProvider(shopsEmpty));

    if (shouldShow) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showOnboardingBottomSheet();
      });
    }
  }

  void _showOnboardingBottomSheet() {
    final dataSource = ref.read(onboardingLocalDataSourceProvider);

    OnboardingBottomSheet.show(
      context,
      onRegisterTap: () {
        Navigator.pop(context);
        dataSource.markOnboardingSeen();
        Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => const ShopRegistrationPage()),
        ).then((result) {
          if (result == true) {
            ref.read(homeNotifierProvider.notifier).refresh();
          }
        });
      },
      onDismiss: () {
        Navigator.pop(context);
        dataSource.markOnboardingSeen();
      },
    );
  }
}

class _SettingsPlaceholder extends StatelessWidget {
  const _SettingsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings_outlined, size: 48, color: AppColors.textHint),
          SizedBox(height: 16),
          Text(
            '설정',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '준비 중입니다',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
