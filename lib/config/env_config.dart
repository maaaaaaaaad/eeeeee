class EnvConfig {
  static const String env = String.fromEnvironment(
    'ENV',
    defaultValue: 'dev',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://125.242.7.11:8080',
  );

  static bool get isDebug => env == 'dev';
  static bool get isProduction => env == 'prod';
}
