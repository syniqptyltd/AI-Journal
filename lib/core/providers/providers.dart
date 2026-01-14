import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';

/// Global providers for core services
/// These are initialized at app startup

/// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// AI service provider
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

/// Check if AI is configured
final isAIConfiguredProvider = Provider<bool>((ref) {
  return ref.watch(aiServiceProvider).isConfigured;
});
