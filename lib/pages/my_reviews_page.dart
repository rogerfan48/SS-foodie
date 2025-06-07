import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:foodie/view_models/my_reviews_vm.dart';
import 'package:foodie/widgets/restaurant/review_list_item.dart';
import 'package:foodie/view_models/account_vm.dart';
import 'package:foodie/repositories/review_repo.dart';

class MyReviewsPage extends StatelessWidget {
  const MyReviewsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final myReviewViewModel = context.watch<MyReviewViewModel?>();
    final currentUserId = context.watch<AccountViewModel>().firebaseUser?.uid;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        title: const Text('My Reviews'),
      ),
      body:
          (myReviewViewModel == null)
              ? const Center(child: Text('Please log in to see your reviews.'))
              : (myReviewViewModel.myReviews.isEmpty)
              ? const Center(child: Text('You have no reviews yet.'))
              : ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                itemCount: myReviewViewModel.myReviews.length,
                itemBuilder: (context, index) {
                  final reviewDisplay = myReviewViewModel.myReviews[index];
                  final review = reviewDisplay.review;
                  final hasAgreed = review.agreedBy.contains(currentUserId);
                  final hasDisagreed = review.disagreedBy.contains(currentUserId);

                  return ReviewListItem(
                    review: reviewDisplay.review,
                    userDataFuture: myReviewViewModel.getUserData(reviewDisplay.review.reviewerID),
                    onAgree:
                        () =>
                            currentUserId != null
                                ? myReviewViewModel.toggleReviewVote(
                                  reviewId: review.reviewID,
                                  currentUserId: currentUserId,
                                  voteType: VoteType.agree,
                                  isCurrentlyVoted: hasAgreed,
                                )
                                : null,
                    onDisagree:
                        () =>
                            currentUserId != null
                                ? myReviewViewModel.toggleReviewVote(
                                  reviewId: review.reviewID,
                                  currentUserId: currentUserId,
                                  voteType: VoteType.disagree,
                                  isCurrentlyVoted: hasDisagreed,
                                )
                                : null,
                  );
                },
              ),
    );
  }
}
