import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/onboarding/data/datasources/onboarding_local_datasource.dart';

final onboardingLocalDataSourceProvider =
    Provider<OnboardingLocalDataSource>((ref) {
  throw UnimplementedError('Must be overridden with SharedPreferences');
});

final shouldShowOnboardingProvider = Provider.family<bool, bool>((ref, shopsEmpty) {
  if (!shopsEmpty) return false;
  final dataSource = ref.watch(onboardingLocalDataSourceProvider);
  return !dataSource.hasSeenOnboarding();
});
