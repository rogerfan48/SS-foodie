import 'package:flutter/material.dart';

enum GenreTags {
  chinese,
  italian,
  hotpot,
}

class GenreTag {
  const GenreTag(this.title, this.color);

  final String title;
  final Color color;
}
