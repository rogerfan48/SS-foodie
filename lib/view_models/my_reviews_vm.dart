import 'package:flutter/material.dart';

class MyReview {
  String? content;
  DateTime? reviewDate;
  int? rating, agree, disagree;
  // List<String>? imageURLs;

  MyReview({
    this.content,
    this.reviewDate,
  });
}

class MyReviewViewModel with ChangeNotifier {
  final List<MyReview> _myReviews = [];

  List<MyReview> get myReviews => _myReviews;

  void addMyReview(MyReview review) {
    _myReviews.add(review);
    notifyListeners();
  }

  void removeMyReview(MyReview review) {
    _myReviews.remove(review);
    notifyListeners();
  }

  void clearMyReviews() {
    _myReviews.clear();
    notifyListeners();
  }
}