import 'package:cook_mate/resources/strings.dart';
import 'package:flutter/material.dart';

class AddRecipe extends StatelessWidget {
  const AddRecipe({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.titleAddRecipe),
      ),
      body: const Center(
        child: Text('Welcome to the Second Page!'),
      ),
    );
  }

}
