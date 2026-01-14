import 'package:flutter/material.dart';
import '../features/example/presentation/screens/example_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Cross-Platform App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ExampleScreen(),
      // TODO: Replace with Splash -> Auth -> Home navigation flow
      // Example of modular navigation and feature-based routing
    );
  }
}
