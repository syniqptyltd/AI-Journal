class AppConfig {
  // Configuration for different environments
  final String apiBaseUrl;
  final String sentryDsn;
  final String environment;

  AppConfig({
    required this.apiBaseUrl,
    required this.sentryDsn,
    required this.environment,
  });

  factory AppConfig.development() {
    return AppConfig(
      apiBaseUrl: 'https://api.dev.example.com',
      sentryDsn: '',
      environment: 'development',
    );
  }

  factory AppConfig.staging() {
    return AppConfig(
      apiBaseUrl: 'https://api.staging.example.com',
      sentryDsn: '',
      environment: 'staging',
    );
  }

  factory AppConfig.production() {
    return AppConfig(
      apiBaseUrl: 'https://api.example.com',
      sentryDsn: '', // Add real Sentry DSN in CI
      environment: 'production',
    );
  }
}
