import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/beautishop/presentation/pages/shop_registration_page.dart';
import 'package:mobile_owner/features/home/presentation/providers/home_provider.dart';
import 'package:mobile_owner/features/home/presentation/widgets/home_tab.dart';
import 'package:mobile_owner/features/home/presentation/widgets/my_shop_tab.dart';
import 'package:mobile_owner/features/home/presentation/widgets/reservation_tab.dart';
import 'package:mobile_owner/features/notification/presentation/providers/notification_provider.dart';
import 'package:mobile_owner/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:mobile_owner/features/reservation/presentation/providers/owner_reservation_list_provider.dart';
import 'package:mobile_owner/features/onboarding/presentation/widgets/onboarding_bottom_sheet.dart';
import 'package:mobile_owner/features/review/presentation/providers/review_tab_provider.dart';
import 'package:mobile_owner/features/review/presentation/widgets/review_tab.dart';
import 'package:mobile_owner/features/settings/presentation/pages/settings_page.dart';
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
    ReservationTab(),
    ReviewTab(),
    MyShopTab(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotifications();
    });
  }

  Future<void> _initializeNotifications() async {
    ref.read(reservationRefreshCallbackProvider.notifier).state = () {
      ref.read(homeNotifierProvider.notifier).refresh();
    };
    await ref.read(localNotificationServiceProvider).initialize();
    ref.read(notificationInitProvider);
  }

  int get _pendingCount {
    final state = ref.watch(ownerReservationListNotifierProvider);
    return state.pendingReservations.length;
  }

  int get _unreadReviewCount {
    final state = ref.watch(reviewTabNotifierProvider);
    return state.totalUnreadCount;
  }

  @override
  Widget build(BuildContext context) {
    _checkOnboarding();

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        body: SafeArea(child: _tabs[_currentIndex]),
        bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.lightPink,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.darkPink),
            label: '홈',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _pendingCount > 0,
              label: Text(
                '$_pendingCount',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: AppColors.darkPink,
              child: const Icon(Icons.calendar_today_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: _pendingCount > 0,
              label: Text(
                '$_pendingCount',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: AppColors.darkPink,
              child: const Icon(Icons.calendar_today, color: AppColors.darkPink),
            ),
            label: '예약',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _unreadReviewCount > 0,
              label: Text(
                '$_unreadReviewCount',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: AppColors.darkPink,
              child: const Icon(Icons.rate_review_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: _unreadReviewCount > 0,
              label: Text(
                '$_unreadReviewCount',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: AppColors.darkPink,
              child: const Icon(Icons.rate_review, color: AppColors.darkPink),
            ),
            label: '리뷰',
          ),
          const NavigationDestination(
            icon: Icon(Icons.store_outlined),
            selectedIcon: Icon(Icons.store, color: AppColors.darkPink),
            label: '내 샵',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: AppColors.darkPink),
            label: '설정',
          ),
        ],
      ),
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
