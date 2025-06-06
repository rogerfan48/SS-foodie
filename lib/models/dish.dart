import 'package:flutter/cupertino.dart';
import 'package:foodie/models/dish_review.dart';

class Dish {
  String? name, summary, bestReviewSummary;
  int? price;
  int? rating;
  List<String>? imageURLs;
  String? mainImageURL;
  List<DishReview>? reviews;

}