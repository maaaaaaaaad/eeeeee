import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/app.dart';
import 'package:mobile_owner/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initializeApp();
  runApp(const ProviderScope(child: OwnerApp()));
}
