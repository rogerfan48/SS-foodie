import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodie/pages/restaurant_info_page.dart';
import 'package:foodie/pages/restaurant_menu_page.dart';
import 'package:foodie/pages/restaurant_reviews_page.dart';
import 'package:go_router/go_router.dart';
import 'package:foodie/pages/loading_page.dart';
import 'package:foodie/pages/main_page.dart';
import 'package:foodie/pages/map_page.dart';
import 'package:foodie/pages/ai_page.dart';
import 'package:foodie/pages/account_page.dart';
import 'package:foodie/pages/restaurant_page.dart';
import 'package:foodie/pages/browsing_history_page.dart';
import 'package:foodie/pages/my_reviews_page.dart';

final routerConfig = GoRouter(
  initialLocation: '/loading',
  routes: [
    GoRoute(
      path: '/loading',
      pageBuilder: (context, state) => NoTransitionPage(child: const LoadingPage()),
    ),
    ShellRoute(
      builder: (context, state, child) => MainPage(child: child), // 傳入 tab page
      routes: [
        GoRoute(
          path: '/map',
          pageBuilder: (context, state) => NoTransitionPage(child: MapPage()),
          routes: [
            ShellRoute(
              builder: (context, state, child) => RestaurantPage(child: child),
              routes: [
                GoRoute(
                  path: 'info',
                  pageBuilder: (context, state) => NoTransitionPage(child: RestaurantInfoPage()),
                ),
                GoRoute(
                  path: 'menu', 
                  pageBuilder: (context, state) => NoTransitionPage(child: RestaurantMenuPage()),
                ),
                GoRoute(
                  path: 'reviews', 
                  pageBuilder: (context, state) => NoTransitionPage(child: RestaurantReviewsPage()),
                ),
              ],
            ),
          ],
        ),
        GoRoute(path: '/ai', pageBuilder: (context, state) => NoTransitionPage(child: AiPage())),
        GoRoute(
          path: '/account',
          pageBuilder: (context, state) => NoTransitionPage(child: AccountPage()),
          routes: [
            GoRoute(
              path: 'history',
              pageBuilder: (context, state) => CupertinoPage(child: const BrowsingHistoryPage()),
            ),
            GoRoute(
              path: 'reviews',
              pageBuilder: (context, state) => CupertinoPage(child: const MyReviewsPage()),),
          ],
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    final currentPath = state.uri.path;
    if (currentPath == '/') {
      return '/loading';
    }
    return null;
  },
  errorBuilder:
      (context, state) => Scaffold(body: Center(child: Text('Page not found: ${state.uri.path}'))),
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
