import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RestaurantPage extends StatelessWidget {
  final Widget child;
  const RestaurantPage({super.key, required this.child});

  static final _tabs = ['/map/info', '/map/menu', '/map/reviews'];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    int activeIndex = _tabs.indexWhere((path) => location.startsWith(path));
    if (activeIndex == -1) activeIndex = 0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    context.go('/map');
                  },
                  icon: Icon(Icons.arrow_back),
                ),
              ],
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    context.go('/map/info');
                  },
                  child: Text("Info"),
                ),
                TextButton(
                  onPressed: () {
                    context.go('/map/menu');
                  },
                  child: Text("Menu"),
                ),
                TextButton(
                  onPressed: () {
                    context.go('/map/reviews');
                  },
                  child: Text("Reviews"),
                ),
              ],
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
