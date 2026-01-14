// Legacy service locator - kept for compatibility
// New code should use Riverpod providers from core/providers/providers.dart

import 'services/storage_service.dart';
import 'services/ai_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() {
    return _instance;
  }

  ServiceLocator._internal();

  late StorageService storageService;
  late AIService aiService;

  Future<void> setup() async {
    storageService = StorageService();
    aiService = AIService();
    await storageService.initialize();
  }
}

final serviceLocator = ServiceLocator();
