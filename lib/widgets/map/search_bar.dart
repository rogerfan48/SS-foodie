import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;

  const SearchBarWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              prefixIcon: Icon(Icons.search),
              hintText: "Search Restaurant",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32)),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }
}

