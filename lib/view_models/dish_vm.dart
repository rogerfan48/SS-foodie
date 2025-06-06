import 'package:flutter/material.dart';
import 'package:foodie/models/dish_review.dart';

class DishViewModel with ChangeNotifier {
  String? summary;
  List<String>? imageURLs;
  List<DishReview>? reviews;
}