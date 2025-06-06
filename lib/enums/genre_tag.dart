import 'package:flutter/material.dart';

enum GenreTags { fastFood, chinese, western, indian, thai, korean, vietnamese, hotpot, barbecue, teppanyaki, streetFood, drink, coffee }

class GenreTag {
  const GenreTag(this.title, this.color);

  final String title;
  final Color color;
}

const genreTags = {
  GenreTags.fastFood: GenreTag("FastFood", Color(0xFFFCADAD)),
  GenreTags.chinese: GenreTag("Chinese", Color(0xFFE45454)),
  GenreTags.western: GenreTag("Western", Color(0xFF0088FF)),
  GenreTags.indian: GenreTag("Indian", Color(0xFFDC9832)),
  GenreTags.thai: GenreTag("Thai", Color(0xFFCFBA30)),            
  GenreTags.korean: GenreTag("Korean", Color(0xFFEBDCE8)),
  GenreTags.vietnamese: GenreTag("Vietnamese", Color(0xFFEBEF1B)),
  GenreTags.hotpot: GenreTag("Hotpot", Color(0xFFDCDCDC)),
  GenreTags.barbecue: GenreTag("Barbecue", Color(0xFFFFA426)),
  GenreTags.teppanyaki: GenreTag("Teppanyaki", Color(0xFF41CF41)),
  GenreTags.streetFood: GenreTag("StreetFood", Color(0xFFD157DA)),
  GenreTags.drink: GenreTag("Drink", Color(0xFF5AE5B5)),
  GenreTags.coffee: GenreTag("Coffee", Color(0xFF38D4E6)),
};
