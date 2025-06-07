import 'package:flutter/material.dart';

// 假設這是一個數據模型，用於傳遞給 ReviewCard
class ReviewCardData {
  final String restaurantName;
  final String content;
  final int rating;
  final int agreeCount;
  final int disagreeCount;
  final String reviewDate; // 例如 "2 months ago" 或 "2025-06-07"
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  ReviewCardData({
    required this.restaurantName,
    required this.content,
    required this.rating,
    required this.agreeCount,
    required this.disagreeCount,
    required this.reviewDate,
    this.onEdit,
    this.onDelete,
  });
}

class ReviewCard extends StatelessWidget {
  final ReviewCardData data;

  const ReviewCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 您可以加入用戶頭像，但在 "MyReview" 頁面可能不需要
                // CircleAvatar(child: Icon(Icons.store)),
                // const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.restaurantName, style: textTheme.titleMedium),
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (index) => Icon(
                              index < data.rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(data.reviewDate, style: textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
                // 編輯和刪除按鈕
                if (data.onEdit != null)
                  IconButton(
                    icon: Icon(Icons.edit_outlined),
                    onPressed: data.onEdit,
                    color: colorScheme.onSurfaceVariant,
                  ),
                if (data.onDelete != null)
                  IconButton(
                    icon: Icon(Icons.delete_outline),
                    onPressed: data.onDelete,
                    color: colorScheme.error,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(data.content, style: textTheme.bodyMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.thumb_up_alt_outlined, size: 16, color: colorScheme.primary),
                const SizedBox(width: 4),
                Text(data.agreeCount.toString(), style: textTheme.bodyMedium),
                const SizedBox(width: 16),
                Icon(Icons.thumb_down_alt_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(data.disagreeCount.toString(), style: textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
