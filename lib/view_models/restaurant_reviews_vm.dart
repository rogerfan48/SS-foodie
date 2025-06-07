import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:foodie/models/restaurant_model.dart';
import 'package:foodie/models/review_model.dart';
import 'package:foodie/repositories/restaurant_repo.dart';
import 'package:foodie/repositories/review_repo.dart';

class RestaurantReview {
  String? restaurantName, content, reviewDate, reviewerID, restaurantID;
  int? priceLevel, rating, agree, disagree;
  List<String>? imageURLs;

  RestaurantReview({
    required this.restaurantName,
    required this.content,
    required this.reviewDate,
    required this.reviewerID,
    required this.restaurantID,
    required this.priceLevel,
    required this.rating,
    required this.agree,
    required this.disagree,
    List<String>? imageURLs,
  }) : imageURLs = imageURLs ?? [];
}

class RestaurantReviewsViewModel with ChangeNotifier {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final ReviewRepository _reviewRepository = ReviewRepository();
  late final StreamSubscription<Map<String, RestaurantModel>?> _restaurantSubscription;
  late final StreamSubscription<Map<String, ReviewModel>?> _reviewSubscription;
  late final String _restaurantName;
  
  final List<RestaurantReview> _reviews = [];
  List<RestaurantReview> get reviews => _reviews;

  RestaurantReviewsViewModel(String restaurantId) {
    late String newName;
    _restaurantSubscription = _restaurantRepository.streamRestaurantMap().listen(
      (restaurantMap) {
        newName = restaurantMap[restaurantId]?.restaurantName ?? "Unknown Restaurant";
        if (newName != _restaurantName) {
          _restaurantName = newName;
          notifyListeners();
        }
      },
    );

    _reviewSubscription = _reviewRepository.streamReviewMap().listen(
      (reviewMap) {
        _reviews.clear();
        reviewMap?.forEach((id, review) {
          _reviews.add(RestaurantReview(
            restaurantName: _restaurantName,
            content: review.content,
            reviewDate: review.reviewDate,
            reviewerID: review.reviewerID,
            restaurantID: review.restaurantID,
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

  void addReview(RestaurantReview review) {
    _reviews.add(review);
    notifyListeners();
  }

  void removeReview(RestaurantReview review) {
    _reviews.remove(review);
    notifyListeners();
  }

  void clearReviews() {
    _reviews.clear();
    notifyListeners();
  }
}