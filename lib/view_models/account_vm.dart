import 'package:flutter/material.dart';
import 'package:foodie/models/restaurant.dart';
import 'package:foodie/models/review.dart';

class ViewedRestaurant {
  final DateTime viewedAt;
  final Restaurant restaurant;
  ViewedRestaurant(this.viewedAt, this.restaurant);
}

class AccountViewModel with ChangeNotifier {
  List<ViewedRestaurant>? viewedRestaurants;
  List<Review>? usrReviews;
}