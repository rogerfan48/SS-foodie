import 'package:flutter/widgets.dart';

class RestaurantReview {
  String? restaurantName, content, reviewDate, reviewerID, restaurantID;
  int? priceLevel, rating, agree, disagree;
  List<String>? imageURLs;
}

class RestaurantReviewsViewModel with ChangeNotifier {
  final List<RestaurantReview> _reviews = [];

  List<RestaurantReview> get reviews => _reviews;

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