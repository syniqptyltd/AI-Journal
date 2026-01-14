import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration for different environments
class AppConfig {
  final String aiApiBaseUrl;
  final String aiApiKey;
  final String aiModel;
  final String sentryDsn;
  final String environment;

  AppConfig({
    required this.aiApiBaseUrl,
    required this.aiApiKey,
    required this.aiModel,
    required this.sentryDsn,
    required this.environment,
  });

  /// Load configuration from environment variables
  factory AppConfig.fromEnvironment() {
    return AppConfig(
      aiApiBaseUrl: dotenv.env['AI_API_BASE_URL'] ?? 'https://api.openai.com/v1',
      aiApiKey: dotenv.env['AI_API_KEY'] ?? '',
      aiModel: dotenv.env['AI_MODEL'] ?? 'gpt-4o-mini',
      sentryDsn: dotenv.env['SENTRY_DSN'] ?? '',
      environment: dotenv.env['ENVIRONMENT'] ?? 'development',
    );
  }

  /// Check if AI is configured
  bool get isAIConfigured =>
      aiApiKey.isNotEmpty && aiApiKey != 'your-api-key-here';

  /// Check if this is a development environment
  bool get isDevelopment => environment == 'development';

  /// Check if this is a production environment
  bool get isProduction => environment == 'production';
}
