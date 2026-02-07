import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/app.dart';
import 'package:mobile_owner/config/app_config.dart';
import 'package:mobile_owner/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:mobile_owner/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initializeApp();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        onboardingLocalDataSourceProvider.overrideWithValue(
          OnboardingLocalDataSourceImpl(prefs: prefs),
        ),
      ],
      child: const OwnerApp(),
    ),
  );
}
