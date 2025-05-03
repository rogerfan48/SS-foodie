import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:foodie/pages/loading_page.dart';
import 'package:foodie/pages/temp_page.dart';

final routerConfig = GoRouter(
  routes: [
    GoRoute(
      path: "/loading",
      pageBuilder: (context, state) => NoTransitionPage(child: const LoadingPage()),
    ),
    GoRoute(
      path: "/map",
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        child: const TempPage(title: 'Flutter Demo Home Page'),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    )
  ],
  initialLocation: '/loading',
  debugLogDiagnostics: true,
  redirect: (context, state) {
    final currentPath = state.uri.path;
    if (currentPath == '/') {
      return '/loading';
    }
    // No redirection needed for other routes
    return null;
  },
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri.path}'),
    ),
  ),
);

class NavigationService {
  late final GoRouter _router;

  NavigationService() {
    _router = routerConfig;
  }

  String _currentPath(BuildContext context) {
    return GoRouterState.of(context).uri.path;
  }
}
