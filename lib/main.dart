import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/app.dart';
import 'core/service_locator.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env.development'); // switch per env
  serviceLocator.setup(); // Initialize dependencies
  runApp(const App());
}
