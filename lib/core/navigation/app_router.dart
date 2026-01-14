import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/main_scaffold.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/journal/screens/journal_screen.dart';
import '../../features/journal/screens/journal_entry_screen.dart';
import '../../features/todos/screens/todo_screen.dart';
import '../../features/breathing/screens/breathing_screen.dart';
import '../../features/insights/screens/insights_screen.dart';

/// App navigation configuration using go_router
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      // Shell route for bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/journal',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: JournalScreen(),
            ),
          ),
          GoRoute(
            path: '/todos',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TodoScreen(),
            ),
          ),
          GoRoute(
            path: '/breathe',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BreathingScreen(),
            ),
          ),
          GoRoute(
            path: '/insights',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: InsightsScreen(),
            ),
          ),
        ],
      ),

      // Full screen routes (outside shell)
      GoRoute(
        path: '/journal/new',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const JournalEntryScreen(),
      ),
      GoRoute(
        path: '/journal/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          // Entry would be passed via extra
          final entry = state.extra;
          return JournalEntryScreen(entry: entry as dynamic);
        },
      ),
    ],
  );
}
