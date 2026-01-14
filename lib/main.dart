import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/app.dart';
import 'core/providers/providers.dart';
import 'features/journal/providers/journal_provider.dart';
import 'features/todos/providers/todo_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for a calm appearance
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env.development');
  } catch (e) {
    // Environment file may not exist in production
    debugPrint('No .env.development file found, using defaults');
  }

  // Create container and initialize services
  final container = ProviderContainer();

  // Initialize storage
  await container.read(storageServiceProvider).initialize();

  // Pre-load data
  await Future.wait([
    container.read(journalProvider.notifier).loadEntries(),
    container.read(todoProvider.notifier).loadTodos(),
  ]);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MindfulPathApp(),
    ),
  );
}
