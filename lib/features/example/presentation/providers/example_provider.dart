import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/example_repository.dart';
import '../../domain/example_usecase.dart';

class ExampleScreenProvider extends ChangeNotifier {
  late ExampleUseCase _useCase;

  ExampleScreenProvider() {
    _useCase = ExampleUseCase();
  }

  Future<void> fetch() async {
    // TODO: call _useCase, update state, notify listeners
    notifyListeners();
  }
}

/// Provider setup for ExampleScreen
final exampleScreenProvider = ChangeNotifierProvider<ExampleScreenProvider>(
  (ref) => ExampleScreenProvider(),
);
