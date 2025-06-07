import 'package:flutter/material.dart';

class HistoryListTile extends StatelessWidget {
  final String restaurantName;
  final String genre;
  final String date;
  final VoidCallback onDelete;

  const HistoryListTile({
    Key? key,
    required this.restaurantName,
    required this.genre,
    required this.date,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(restaurantName, style: theme.textTheme.titleMedium),
      subtitle: Row(
        children: [
          Text(date, style: theme.textTheme.bodySmall),
          const SizedBox(width: 8),
          Chip(
            label: Text(genre),
            padding: EdgeInsets.zero,
            labelStyle: theme.textTheme.labelSmall,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
      trailing: IconButton(icon: const Icon(Icons.close), onPressed: onDelete),
    );
  }
}
