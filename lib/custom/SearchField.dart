import 'package:flutter/material.dart';

import '../resources/strings.dart';

class SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const SearchField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        hintText: AppStrings.hintSearchRecipes,
        prefixIcon: Icon(Icons.search, color: Colors.black),
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey)
        ),
      ),
      onChanged: onChanged,
    );
  }
}