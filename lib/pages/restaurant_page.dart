import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RestaurantPage extends StatelessWidget {
  const RestaurantPage({super.key});

  static final _tabs = [
    '/map',
    '/ai',
    '/account',
  ];

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: (){context.go('/map');}, icon: Icon(Icons.arrow_back));
  }
}

