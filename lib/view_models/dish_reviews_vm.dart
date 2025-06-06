import 'package:flutter/material.dart';

class DishReview {
  String? dishName, content, reviewDate, reviewerID, restaurantID, dishID;
  int? priceLevel, rating, agree, disagree;
  List<String>? imageURLs;
}

class DishReviewsViewModel with ChangeNotifier {
  final List<DishReview> _reviews = [];

  List<DishReview> get reviews => _reviews;

  void addReview(DishReview review) {
    _reviews.add(review);
    notifyListeners();
  }

  void removeReview(DishReview review) {
    _reviews.remove(review);
    notifyListeners();
  }

  void clearReviews() {
    _reviews.clear();
    notifyListeners();
  }
}