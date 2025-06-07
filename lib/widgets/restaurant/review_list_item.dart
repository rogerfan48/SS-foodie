import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodie/models/user_model.dart';
import 'package:foodie/models/review_model.dart';
import 'package:foodie/repositories/review_repo.dart';
import 'package:foodie/view_models/account_vm.dart';
import 'package:foodie/view_models/restaurant_detail_vm.dart';

class ReviewListItem extends StatelessWidget {
  final ReviewModel review;
  final Future<UserModel?> userDataFuture;
  final VoidCallback? onAgree;
  final VoidCallback? onDisagree;
  const ReviewListItem({
    super.key,
    required this.review,
    required this.userDataFuture,
    this.onAgree,
    this.onDisagree,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final currentUserId = context.watch<AccountViewModel>().firebaseUser?.uid;

    final bool hasAgreed = currentUserId != null && review.agreedBy.contains(currentUserId);
    final bool hasDisagreed = currentUserId != null && review.disagreedBy.contains(currentUserId);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<UserModel?>(
            future: userDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done || !snapshot.hasData) {
                return const CircleAvatar(child: Icon(Icons.person_outline));
              }
              final user = snapshot.data;
              return CircleAvatar(
                backgroundImage: (user?.photoURL != null) ? NetworkImage(user!.photoURL!) : null,
                child: (user?.photoURL == null) ? const Icon(Icons.person_outline) : null,
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FutureBuilder<UserModel?>(
                      future: userDataFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done || !snapshot.hasData) {
                          return Text('Loading...', style: textTheme.titleSmall);
                        }
                        return Text(
                          snapshot.data?.userName ?? 'Unknown User',
                          style: textTheme.titleSmall,
                        );
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        hasAgreed ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                        size: 18,
                        color: hasAgreed ? colorScheme.primary : null,
                      ),
                      onPressed: onAgree,
                    ),
                    Text((review.agreedBy.length - 1).toString()),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        hasDisagreed ? Icons.thumb_down_alt : Icons.thumb_down_alt_outlined,
                        size: 18,
                        color: hasDisagreed ? Colors.grey : null,
                      ),
                      onPressed: onDisagree,
                    ),
                    Text((review.disagreedBy.length - 1).toString()),
                  ],
                ),
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (i) => Icon(
                        i < review.rating ? Icons.star : Icons.star_border,
                        size: 16,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(review.reviewDate, style: textTheme.bodySmall), // 格式化日期
                  ],
                ),
                const SizedBox(height: 8),
                Text(review.content, style: textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
