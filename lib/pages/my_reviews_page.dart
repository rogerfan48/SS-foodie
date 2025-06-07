import 'package:flutter/material.dart';
import 'package:foodie/view_models/my_reviews_vm.dart';
import 'package:foodie/widgets/review_card.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MyReviewsPage extends StatelessWidget {
  const MyReviewsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final myReviewViewModel = context.watch<MyReviewViewModel?>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        title: const Text('My Reviews'),
      ),
      body: (myReviewViewModel == null || myReviewViewModel.myReviews.isEmpty)
          ? const Center(child: Text('You have no reviews yet.'))
          : ListView.builder(
              itemCount: myReviewViewModel.myReviews.length,
              itemBuilder: (context, index) {
                final reviewDisplay = myReviewViewModel.myReviews[index];
                final reviewData = ReviewCardData(
                  restaurantName: reviewDisplay.restaurantName,
                  content: reviewDisplay.review.content,
                  rating: reviewDisplay.review.rating,
                  agreeCount: reviewDisplay.review.agree,
                  disagreeCount: reviewDisplay.review.disagree,
                  reviewDate: reviewDisplay.review.reviewDate, // 您可以進一步格式化日期
                  onEdit: () {
                    // TODO: 執行編輯評論的邏輯
                  },
                  onDelete: () {
                    // TODO: 執行刪除評論的邏輯
                  },
                );
                return ReviewCard(data: reviewData);
              },
            ),
    );
  }
}
