import 'package:flutter/material.dart';

enum GenreTags { chinese, western, hotpot }

class GenreTag {
  const GenreTag(this.title, this.color);

  final String title;
  final Color color;
}

const genreTags = {
  GenreTags.chinese: GenreTag("Chinese", Color(0xE45454FF)),
  GenreTags.western: GenreTag("Western", Color(0x0088FFFF)),
  GenreTags.hotpot: GenreTag("Hotpot", Color(0xDCDCDCFF)),
};
