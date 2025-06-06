import 'package:flutter/material.dart';
import 'package:foodie/models/dish.dart';


class RestaurantMenuViewModel with ChangeNotifier {
  Map<String, List<Dish>>? dishesMap;
}