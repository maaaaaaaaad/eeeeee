import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:mobile_owner/features/onboarding/presentation/providers/onboarding_provider.dart';

class MockOnboardingLocalDataSource extends Mock
    implements OnboardingLocalDataSource {}

void main() {
  late MockOnboardingLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockOnboardingLocalDataSource();
  });

  group('shouldShowOnboarding', () {
    test('should return true when shops empty and not seen', () {
      when(() => mockDataSource.hasSeenOnboarding()).thenReturn(false);

      final container = ProviderContainer(
        overrides: [
          onboardingLocalDataSourceProvider.overrideWithValue(mockDataSource),
        ],
      );
      addTearDown(container.dispose);

      final result = container.read(shouldShowOnboardingProvider(true));
      expect(result, true);
    });

    test('should return false when shops are not empty', () {
      when(() => mockDataSource.hasSeenOnboarding()).thenReturn(false);

      final container = ProviderContainer(
        overrides: [
          onboardingLocalDataSourceProvider.overrideWithValue(mockDataSource),
        ],
      );
      addTearDown(container.dispose);

      final result = container.read(shouldShowOnboardingProvider(false));
      expect(result, false);
    });

    test('should return false when already seen', () {
      when(() => mockDataSource.hasSeenOnboarding()).thenReturn(true);

      final container = ProviderContainer(
        overrides: [
          onboardingLocalDataSourceProvider.overrideWithValue(mockDataSource),
        ],
      );
      addTearDown(container.dispose);

      final result = container.read(shouldShowOnboardingProvider(true));
      expect(result, false);
    });
  });
}
