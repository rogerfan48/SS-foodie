import 'package:flutter/material.dart';

enum HalalTags { yes, no }

class HalalTag {
  const HalalTag(this.title, this.icon);

  final String title;
  final Icon icon;
}

const halalTags = {
  HalalTags.yes: true, // TODO:
  HalalTags.no: true, // TODO:
}
