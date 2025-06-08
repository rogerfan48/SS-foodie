import 'package:flutter/material.dart';
import 'package:foodie/enums/genre_tag.dart';

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
    // Safely handle the genre tag - try to convert from string or fallback to a default
    GenreTag genreTag;
    try {
      // Try to convert directly if it's an enum key
      genreTag = GenreTag.fromString(genre);
    } catch (e) {
      // If that fails, try searching for a matching title
      genreTag = genreTags.values.firstWhere(
        (tag) => tag.title == genre,
        orElse: () => const GenreTag("Unknown", Color(0xFFCCCCCC)),
      );
    }

    return Dismissible(
      key: UniqueKey(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Theme.of(context).colorScheme.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => onDelete(),
      child: ListTile(
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0, bottom: 4.0, top: 4.0),
              child: Text(restaurantName, style: theme.textTheme.bodyLarge)
            ),
            // Text(restaurantName, style: theme.textTheme.bodyLarge),
            // Expanded(child: Text(restaurantName, style: theme.textTheme.bodyLarge)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: genreTag.color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                genreTag.title,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        subtitle: Text(date, style: theme.textTheme.bodySmall),
        trailing: IconButton(icon: const Icon(Icons.close), onPressed: onDelete),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4.0),
      ),
    );
  }
}
