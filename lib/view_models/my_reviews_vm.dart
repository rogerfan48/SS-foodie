import 'dart:async';
import 'package:flutter/material.dart';
import 'package:foodie/models/review_model.dart';
import 'package:foodie/repositories/review_repo.dart';

class MyReview {
  String? content;
  DateTime? reviewDate;
  int? rating, agree, disagree;
  // List<String>? imageURLs;

  MyReview({
    required this.content,
    required this.reviewDate,
    required this.rating,
    required this.agree,
    required this.disagree,
  });
}

class MyReviewViewModel with ChangeNotifier {
  final String _userId;
  final ReviewRepository _reviewRepository;
  late final StreamSubscription<Map<String, ReviewModel>> _reviewSubscription;
  final List<MyReview> _myReviews = [];

  List<MyReview> get myReviews => _myReviews;

  MyReviewViewModel(this._userId, this._reviewRepository) {
    _reviewSubscription = _reviewRepository
      .streamReviewMap()
      .listen((allReviews) {
        _myReviews.clear();
        allReviews.forEach((key, review) {
          if (review.reviewerID == _userId) {
            _myReviews.add(MyReview(
              content:    review.content,
              reviewDate: DateTime.parse(review.reviewDate),
              rating:     review.rating,
              agree:      review.agree,
              disagree:   review.disagree,
            ));
          }
        });
        notifyListeners();
      });
  }

  @override
  void dispose() {
    _reviewSubscription.cancel();
    super.dispose();
  }
}
