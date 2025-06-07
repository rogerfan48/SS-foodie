import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foodie/models/dish_model.dart';
import 'package:foodie/models/review_model.dart';
import 'package:foodie/models/specific_review_state.dart';
import 'package:foodie/repositories/review_repo.dart';
import 'package:foodie/services/storage_service.dart';
import 'package:image_picker/image_picker.dart';

class WriteReviewViewModel with ChangeNotifier {
  final String _restaurantId;
  final String _currentUserId;
  final Map<String, List<DishModel>> _categorizedMenu;
  final ReviewRepository _reviewRepository;
  final StorageService _storageService;
  final ImagePicker _picker = ImagePicker();

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // State variables
  final List<SpecificReviewState> specificReviews = [SpecificReviewState()]; // one initial review
  final TextEditingController overallContentController = TextEditingController();
  int overallRating = 0;
  int? selectedPrice;

  // Getters
  Map<String, List<DishModel>> get categorizedMenu => _categorizedMenu;

  WriteReviewViewModel({
    required String restaurantId,
    required String currentUserId,
    required Map<String, List<DishModel>> categorizedMenu,
    required ReviewRepository reviewRepository,
    required StorageService storageService,
  }) : _restaurantId = restaurantId,
       _currentUserId = currentUserId,
       _categorizedMenu = categorizedMenu,
       _reviewRepository = reviewRepository,
       _storageService = storageService;

  void addSpecificReview() {
    specificReviews.add(SpecificReviewState());
    notifyListeners();
  }

  void removeSpecificReview(int index) {
    if (specificReviews.length > 1) {
      specificReviews.removeAt(index);
      notifyListeners();
    }
  }

  void setDish(int index, DishModel dish) {
    specificReviews[index].selectedDish = dish;
    notifyListeners();
  }

  void setDishRating(int index, int rating) {
    specificReviews[index].rating = rating;
    notifyListeners();
  }

  void setOverallRating(int rating) {
    overallRating = rating;
    notifyListeners();
  }

  void setPrice(int price) {
    selectedPrice = price;
    notifyListeners();
  }

  Future<void> pickImages(int index) async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage(imageQuality: 50);
    if (pickedFiles.isNotEmpty) {
      specificReviews[index].images.addAll(pickedFiles);
      notifyListeners();
    }
  }

  void removeImage(int reviewIndex, int imageIndex) {
    specificReviews[reviewIndex].images.removeAt(imageIndex);
    notifyListeners();
  }

  Future<List<String>> _uploadImages(List<XFile> images) async {
    if (images.isEmpty) return [];

    // 為每一個圖片檔案建立一個上傳任務 (Future)
    final uploadTasks =
        images.map((imageFile) {
          return _storageService.uploadReviewImage(
            file: File(imageFile.path),
            userId: _currentUserId,
          );
        }).toList();

    // 等待所有上傳任務完成
    return await Future.wait(uploadTasks);
  }

  Future<bool> submitReview() async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    notifyListeners();

    try {
      // 處理對菜色的評論
      for (final specificReview in specificReviews) {
        bool hasRating = specificReview.rating > 0;
        bool hasContent = specificReview.contentController.text.isNotEmpty;
        bool hasDish = specificReview.selectedDish != null;

        if (hasDish && (hasRating || hasContent)) {
          // 1. 先上傳圖片
          final imageUris = await _uploadImages(specificReview.images);
          // 2. 建立 ReviewModel
          final newReview = ReviewModel(
            reviewerID: _currentUserId,
            restaurantID: _restaurantId,
            dishID: specificReview.selectedDish!.dishId,
            rating: specificReview.rating,
            content: specificReview.contentController.text,
            reviewDate: DateTime.now().toIso8601String(),
            priceLevel: null,
            reviewImgURLs: imageUris,
          );
          await _reviewRepository.addReview(newReview);
        }
      }

      // 處理對餐廳的總體評論
      bool hasOverallRating = overallRating > 0;
      bool hasOverallContent = overallContentController.text.isNotEmpty;
      if (hasOverallRating || hasOverallContent) {
        final newReview = ReviewModel(
          reviewerID: _currentUserId,
          restaurantID: _restaurantId,
          dishID: null,
          rating: overallRating,
          content: overallContentController.text,
          reviewDate: DateTime.now().toIso8601String(),
          priceLevel: selectedPrice,
          reviewImgURLs: [],
        );
        await _reviewRepository.addReview(newReview);
      }
      return true;
    } catch (e) {
      print("Error submitting review: $e");
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (var review in specificReviews) {
      review.contentController.dispose();
    }
    overallContentController.dispose();
    super.dispose();
  }
}
