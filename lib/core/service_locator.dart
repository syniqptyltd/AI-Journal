// Example of basic dependency injection setup
// Expand this to provide repositories, use cases, and widgets

import '../features/example/domain/example_usecase.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() {
    return _instance;
  }

  ServiceLocator._internal();

  late ExampleUseCase exampleUseCase;

  void setup() {
    // Register repositories
    // exampleRepository = ExampleRepositoryImpl();

    // Register use cases
    exampleUseCase = ExampleUseCase();

    // Register services
    // apiService = ApiService();
  }
}

final serviceLocator = ServiceLocator();
