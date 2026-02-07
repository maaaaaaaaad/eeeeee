import 'package:shared_preferences/shared_preferences.dart';

abstract class OnboardingLocalDataSource {
  bool hasSeenOnboarding();
  Future<void> markOnboardingSeen();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  static const _onboardingSeenKey = 'onboarding_shop_registration_seen';

  final SharedPreferences _prefs;

  OnboardingLocalDataSourceImpl({required SharedPreferences prefs})
      : _prefs = prefs;

  @override
  bool hasSeenOnboarding() {
    return _prefs.getBool(_onboardingSeenKey) ?? false;
  }

  @override
  Future<void> markOnboardingSeen() {
    return _prefs.setBool(_onboardingSeenKey, true);
  }
}
