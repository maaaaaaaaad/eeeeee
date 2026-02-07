import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late OnboardingLocalDataSourceImpl dataSource;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('OnboardingLocalDataSource', () {
    test('should return false when onboarding has not been seen', () async {
      final prefs = await SharedPreferences.getInstance();
      dataSource = OnboardingLocalDataSourceImpl(prefs: prefs);

      final result = dataSource.hasSeenOnboarding();

      expect(result, false);
    });

    test('should return true after marking onboarding as seen', () async {
      final prefs = await SharedPreferences.getInstance();
      dataSource = OnboardingLocalDataSourceImpl(prefs: prefs);

      await dataSource.markOnboardingSeen();
      final result = dataSource.hasSeenOnboarding();

      expect(result, true);
    });
  });
}
