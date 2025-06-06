import 'package:flutter/material.dart';

enum HalalTags { yes, no }

class HalalTag {
  const HalalTag(this.title, this.image);

  final String title;
  final Image image;
}

final halalTags = {
  HalalTags.yes: ("Yes", Image.asset('assets/imgs/halal.png', width: 150)), 
  HalalTags.no: ("No", Image.asset('assets/imgs/halal.png', width: 150)), 
};
