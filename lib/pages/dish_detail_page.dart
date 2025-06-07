import 'package:flutter/material.dart';

class DishDetailPage extends StatelessWidget {
  final String dishId;
  const DishDetailPage({super.key, required this.dishId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Dish: $dishId')));
  }
}
