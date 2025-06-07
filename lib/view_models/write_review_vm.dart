import 'package:flutter/material.dart';
import 'package:foodie/models/dish_model.dart';
import 'package:foodie/models/specific_review_state.dart';
import 'package:image_picker/image_picker.dart';

class WriteReviewViewModel with ChangeNotifier {
  final Map<String, List<DishModel>> _categorizedMenu;
  final ImagePicker _picker = ImagePicker();

  // State variables
  final List<SpecificReviewState> specificReviews = [SpecificReviewState()]; // one initial review
  final TextEditingController overallContentController = TextEditingController();
  int overallRating = 0;
  int? selectedPrice;

  // Getters
  Map<String, List<DishModel>> get categorizedMenu => _categorizedMenu;

  WriteReviewViewModel(this._categorizedMenu);

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
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      specificReviews[index].images.addAll(pickedFiles);
      notifyListeners();
    }
  }

  void submitReview() {
    // TODO: 整合所有表單數據，轉換成 ReviewModel，並呼叫 ReviewRepository 的方法上傳
    print('--- Submitting Review ---');
    for (var i = 0; i < specificReviews.length; i++) {
      print('Dish Review #${i+1}:');
      print('Dish: ${specificReviews[i].selectedDish?.dishName}');
      print('Rating: ${specificReviews[i].rating}');
      print('Content: ${specificReviews[i].contentController.text}');
      print('Images: ${specificReviews[i].images.length}');
    }
    print('-------------------------');
    print('Overall Rating: $overallRating');
    print('Overall Content: ${overallContentController.text}');
    print('Price Level: $selectedPrice');
    print('-------------------------');
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
