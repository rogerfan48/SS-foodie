import 'package:flutter/material.dart';
import 'package:foodie/models/review_model.dart';

class ReviewListItem extends StatelessWidget {
  final ReviewModel review;
  const ReviewListItem({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(child: Icon(Icons.person_outline)), // 評論者頭像
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // TODO: 根據 reviewerID 查找真實用戶名
                    Text('User ${review.reviewerID.substring(0, 6)}', style: textTheme.titleSmall),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.thumb_up_alt_outlined, size: 18), onPressed: () {}),
                    Text(review.agree.toString()),
                    const SizedBox(width: 8),
                    IconButton(icon: const Icon(Icons.thumb_down_alt_outlined, size: 18), onPressed: () {}),
                    Text(review.disagree.toString()),
                  ],
                ),
                Row(
                  children: [
                    ...List.generate(5, (i) => Icon(i < review.rating ? Icons.star : Icons.star_border, size: 16, color: Colors.amber)),
                    const SizedBox(width: 8),
                    Text(review.reviewDate, style: textTheme.bodySmall), // 格式化日期
                  ],
                ),
                const SizedBox(height: 8),
                Text(review.content, style: textTheme.bodyMedium),
              ],
            ),
          )
        ],
      ),
    );
  }
}
