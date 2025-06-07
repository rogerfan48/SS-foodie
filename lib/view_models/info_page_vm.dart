import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodie/enums/genre_tag.dart';
import 'package:foodie/enums/vegan_tag.dart';
import 'package:foodie/models/restaurant_model.dart';
import 'package:foodie/models/review_model.dart';
import 'package:foodie/repositories/restaurant_repo.dart';
import 'package:foodie/repositories/review_repo.dart';

class RestaurantInfo {
  final String restaurantName;
  final String summary;
  final String address;
  final String phoneNumber;
  final Map<String, String> businessHour;
  final List<String> imageURLs;
  final List<GenreTag> genreTags;
  final VeganTag veganTag;
  final int priceLevel, rating;

  RestaurantInfo({
    required this.restaurantName,
    required this.summary,
    required this.address,
    required this.phoneNumber,
    required this.businessHour,
    required this.genreTags,
    required this.veganTag,
    required this.priceLevel,
    required this.rating,
    required this.imageURLs,
  });
}

class InfoPageViewModel with ChangeNotifier {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final ReviewRepository     _reviewRepository     = ReviewRepository();

  final String restaurantId;                 // ← store the passed‐in ID
  late RestaurantInfo  _restaurantInfo;
  List<ReviewModel>    _restaurantReviews = [];  // ← filtered reviews
  late RestaurantModel _restaurant;
  StreamSubscription<Map<String, RestaurantModel>>? _restaurantSubscription;
  StreamSubscription<Map<String, ReviewModel>?>?   _reviewSubscription;

  RestaurantInfo get restaurantInfo    => _restaurantInfo;
  // List<ReviewModel> get restaurantReviews => _restaurantReviews;

  InfoPageViewModel(this.restaurantId) {
    _reviewSubscription = _reviewRepository.streamReviewMap().listen(
      (allReviews) {
        _restaurantReviews = allReviews?.values
          .where((r) => r.restaurantID == restaurantId)
          .toList() 
          ?? [];
        notifyListeners();
      },
    );

    _restaurantSubscription = _restaurantRepository.streamRestaurantMap().listen(
      (restaurantMap) {
        _restaurant = restaurantMap[restaurantId]!;
        _restaurantInfo = RestaurantInfo(
          restaurantName: _restaurant.restaurantName,
          summary:        _restaurant.summary,
          address:        _restaurant.address,
          phoneNumber:    _restaurant.phoneNumber,
          businessHour:   _restaurant.businessHour,
          genreTags:      _restaurant.genreTags.map(GenreTag.fromString).toList(),
          veganTag:       calculateVeganTag(),
          priceLevel:     calculatePriceLevel(),
          rating:         calculateRating(),
          imageURLs:      getImageURLs(),
        );
        notifyListeners();
      },
    );
  }

  VeganTag calculateVeganTag() {
    // Collect all dish tags (skip nulls)
    final tags = _restaurant.menuMap.values
      .map((dish) => dish.veganTag)
      .map((tag) => VeganTag.fromString(tag))
      .toList();

    if (tags.isEmpty) {
      return veganTags[VeganTags.nonVegetarian]!;
    }
    // Example policy: if any dish is non‐vegetarian → nonVegetarian
    if (tags.any((t) => t.title == veganTags[VeganTags.nonVegetarian]!.title)) {
      return veganTags[VeganTags.nonVegetarian]!;
    }
    // else if any dish is vegetarian (or partial) → vegetarian
    if (tags.any((t) => t.title == veganTags[VeganTags.vegetarian]!.title)) {
      return veganTags[VeganTags.vegetarian]!;
    }
    // else if any dish is lactoOvo → lactoOvo
    if (tags.any((t) => t.title == veganTags[VeganTags.lacto]!.title)) {
      return veganTags[VeganTags.lacto]!;
    }
    // else if any dish is veganPartial
    if (tags.any((t) => t.title == veganTags[VeganTags.veganPartial]!.title)) {
      return veganTags[VeganTags.veganPartial]!;
    }
    // otherwise all dishes are fully vegan
    return veganTags[VeganTags.vegan]!;
  }


  int calculateRating() {
    if (_restaurantReviews.isEmpty) return 3; // default if no reviews
    final total = _restaurantReviews.fold<int>(
      0,
      (sum, review) => sum + review.rating,
    );
    return (total / _restaurantReviews.length).round();
  }

  int calculatePriceLevel() {
    if (_restaurantReviews.isEmpty) return 2;
    final totalPriceLevel = _restaurantReviews.fold<int>(
      0, (sum, review) => sum + review.priceLevel!,
    );
    return (totalPriceLevel / _restaurantReviews.length).round();
  }

  List<String> getImageURLs() {
    if(_restaurantReviews.isEmpty) return [];
    final imageURLs = _restaurantReviews.expand((review) => review.reviewImgURLs).toList();
    return imageURLs;
  }

  @override
  void dispose() {
    _restaurantSubscription?.cancel();
    _reviewSubscription?.cancel();
    super.dispose();
  }
}