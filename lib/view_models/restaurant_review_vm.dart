import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:foodie/models/restaurant_review.dart';

class RestaurantReviewViewModel with ChangeNotifier {
  Map<int, Float>? ratingDistribution;
  List<RestaurantReview>? reviews;
}