import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodie/models/restaurant_model.dart';
import 'package:foodie/models/review_model.dart';
import 'package:foodie/repositories/restaurant_repo.dart';
import 'package:foodie/repositories/review_repo.dart';

class DishReview {
  String? dishName, content, reviewDate, reviewerID, restaurantID, dishID;
  int? priceLevel, rating, agree, disagree;
  List<String>? imageURLs;

  DishReview({
    required this.dishName,
    required this.content,
    required this.reviewDate,
    required this.reviewerID,
    required this.restaurantID,
    required this.dishID,
    required this.priceLevel,
    required this.rating,
    required this.agree,
    required this.disagree,
    List<String>? imageURLs,
  }) : imageURLs = imageURLs ?? [];
}

class DishReviewsViewModel with ChangeNotifier {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final ReviewRepository _reviewRepository = ReviewRepository();
  late final StreamSubscription<Map<String, RestaurantModel>?> _restaurantSubscription;
  late final StreamSubscription<Map<String, ReviewModel>?> _reviewSubscription;
  late final String _dishName;

  final List<DishReview> _reviews = [];
  List<DishReview> get reviews => _reviews;

  DishReviewsViewModel(String restaurantId, String dishId) {
    late String newName;
    _restaurantSubscription = _restaurantRepository.streamRestaurantMap().listen(
      (restaurantMap) {
        newName = restaurantMap[restaurantId]?.menuMap[dishId]?.dishName ?? "Unknown Dish";
        if(newName != _dishName) {
          _dishName = newName;
          notifyListeners();
        }
    });

    _reviewSubscription = _reviewRepository.streamReviewMap().listen(
      (reviewMap) {
        _reviews.clear();
        reviewMap?.forEach((id, review) {
          _reviews.add(DishReview(
            dishName: _dishName,
            content: review.content,
            reviewDate: review.reviewDate,
            reviewerID: review.reviewerID,
            restaurantID: review.restaurantID,
            dishID: review.dishID,
            priceLevel: review.priceLevel,
            rating: review.rating,
            agree: review.agree,
            disagree: review.disagree,
            imageURLs: List<String>.from(review.reviewImgURLs),
          ));
        });
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _restaurantSubscription.cancel();
    _reviewSubscription.cancel();
    super.dispose();
  }

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