import 'package:cook_mate/helper/DatabaseHelper.dart';
import 'package:cook_mate/resources/strings.dart';
import 'package:flutter/material.dart';

class AddRecipe extends StatefulWidget {
  final int recipeId;

  const AddRecipe(this.recipeId, {super.key});

  @override
  State<AddRecipe> createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();

  late Future<Map<String, dynamic>> _currentRecipe;
  bool _isModified = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.recipeId > 0) {
      _currentRecipe = _fetchRecipeDetails(widget.recipeId);
    }
  }

  Future<Map<String, dynamic>> _fetchRecipeDetails(int recipeId) async {
    final result = await DatabaseHelper.instance.getRecipeForId(recipeId);
    if (result.isNotEmpty) {
      return result.first;
    } else {
      throw Exception(AppStrings.messageRecipeNotFound);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        final NavigatorState navigator = Navigator.of(context);
        navigator.pop(_isModified);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.titleAddRecipe),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          actions: [
            IconButton(onPressed: (_saveRecipe), icon: const Icon(Icons.save))
          ],
        ),
        body: FutureBuilder<Map<String, dynamic>>(
            future: _currentRecipe,
            builder: (context, snapshot) {
              final recipe = snapshot.data;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildTextFormField(
                        controller: _titleController,
                        labelText: AppStrings.labelRecipeName,
                        content: recipe != null
                            ? recipe[DatabaseHelper.columnTitle]
                            : "",
                        minLines: 1,
                        maxLines: 2,
                        validator: (value) => value == null || value.isEmpty
                            ? AppStrings.labelRecipeName
                            : null,
                      ),
                      _buildTextFormField(
                        controller: _descriptionController,
                        labelText: AppStrings.labelDescription,
                        content: recipe != null
                            ? recipe[DatabaseHelper.columnDescription]
                            : "",
                        minLines: 1,
                        maxLines: 3,
                        validator: (value) => value == null || value.isEmpty
                            ? AppStrings.labelDescriptionPrompt
                            : null,
                      ),
                      _buildTextFormField(
                        controller: _ingredientsController,
                        labelText: AppStrings.labelIngredients,
                        content: recipe != null
                            ? recipe[DatabaseHelper.columnIngredients]
                            : "",
                        minLines: 3,
                        maxLines: 10,
                        validator: (value) => value == null || value.isEmpty
                            ? AppStrings.labelIngredientsPrompt
                            : null,
                      ),
                      _buildTextFormField(
                        controller: _instructionsController,
                        labelText: AppStrings.labelSteps,
                        content: recipe != null
                            ? recipe[DatabaseHelper.columnInstructions]
                            : "",
                        minLines: 3,
                        maxLines: 10,
                        validator: (value) => value == null || value.isEmpty
                            ? AppStrings.labelStepsPrompt
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  void _saveRecipe() {
    if (_formKey.currentState?.validate() ?? false) {
      if (widget.recipeId > 0) {
        _isModified = true;
      }
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

    final result = await DatabaseHelper.instance.insertOrUpdate(row, widget.recipeId);
    if (mounted && result > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.messageAddRecipeSuccess)),
      );
      Navigator.of(context).pop(_isModified);
    }
  }
}

Widget _buildTextFormField({
  required TextEditingController controller,
  required String labelText,
  required String? content,
  required int minLines,
  required int maxLines,
  required String? Function(String?) validator,
}) {
  controller.text = content ?? "";
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
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
      ),
      textAlignVertical: TextAlignVertical.top,
      textAlign: TextAlign.start,
      validator: validator,
    ),
  );
}
