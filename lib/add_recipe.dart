import 'package:cook_mate/helper/DatabaseHelper.dart';
import 'package:cook_mate/resources/strings.dart';
import 'package:flutter/material.dart';

class AddRecipe extends StatefulWidget {
  const AddRecipe({super.key});

  @override
  State<AddRecipe> createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.titleAddRecipe),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(onPressed: (_saveRecipe), icon: const Icon(Icons.save))
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
                controller: _titleController,
                labelText: AppStrings.labelRecipeName,
                minLines: 1,
                maxLines: 2,
                validator: (value) => value == null || value.isEmpty
                    ? AppStrings.labelRecipeName
                    : null,
              ),
              _buildTextFormField(
                controller: _descriptionController,
                labelText: AppStrings.labelDescription,
                minLines: 1,
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? AppStrings.labelDescriptionPrompt
                    : null,
              ),
              _buildTextFormField(
                controller: _ingredientsController,
                labelText: AppStrings.labelIngredients,
                minLines: 3,
                maxLines: 10,
                validator: (value) => value == null || value.isEmpty
                    ? AppStrings.labelIngredientsPrompt
                    : null,
              ),
              _buildTextFormField(
                controller: _instructionsController,
                labelText: AppStrings.labelSteps,
                minLines: 3,
                maxLines: 10,
                validator: (value) => value == null || value.isEmpty
                    ? AppStrings.labelStepsPrompt
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveRecipe() {
    if (_formKey.currentState?.validate() ?? false) {
      _addRecipeIntoDatabase();
    }
  }

  Future<void> _addRecipeIntoDatabase() async {
    final title = _titleController.text;
    final description = _descriptionController.text;
    final ingredients = _ingredientsController.text;
    final instructions = _instructionsController.text;

    final row = {
      DatabaseHelper.columnTitle: title,
      DatabaseHelper.columnDescription: description,
      DatabaseHelper.columnIngredients: ingredients,
      DatabaseHelper.columnInstructions: instructions
    };

    final result = await DatabaseHelper.instance.insert(row);
    if (mounted && result > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.messageAddRecipeSuccess)),
      );
      Navigator.of(context).pop(true);
    }
  }
}

Widget _buildTextFormField({
  required TextEditingController controller,
  required String labelText,
  required int minLines,
  required int maxLines,
  required String? Function(String?) validator,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12.0),
    child: TextFormField(
      controller: controller,
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
      validator: validator,
    ),
  );
}
