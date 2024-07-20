import 'package:cook_mate/resources/strings.dart';
import 'package:flutter/material.dart';

class ViewRecipe extends StatefulWidget {
  const ViewRecipe({super.key});

  @override
  State<ViewRecipe> createState() => _ViewRecipeState();
}

class _ViewRecipeState extends State<ViewRecipe> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.titleAddRecipe),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () {},)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildTextFormField(
                  labelText: AppStrings.labelRecipeName,
                  minLines: 1,
                  maxLines: 2
              ),
              _buildTextFormField(
                labelText: AppStrings.labelDescription,
                minLines: 1,
                maxLines: 3,
              ),
              _buildTextFormField(
                labelText: AppStrings.labelIngredients,
                minLines: 3,
                maxLines: 10,
              ),
              _buildTextFormField(
                labelText: AppStrings.labelSteps,
                minLines: 3,
                maxLines: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String labelText,
    required int minLines,
    required int maxLines,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        minLines: minLines,
        maxLines: maxLines,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          alignLabelWithHint: true,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        ),
        textAlignVertical: TextAlignVertical.top,
        textAlign: TextAlign.start,
      ),
    );
  }
}
