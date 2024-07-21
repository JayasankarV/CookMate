import 'package:cook_mate/ui/add_recipe.dart';
import 'package:cook_mate/helper/database_helper.dart';
import 'package:cook_mate/resources/strings.dart';
import 'package:flutter/material.dart';

import '../helper/dialog_builder.dart';

class ViewRecipe extends StatefulWidget {
  final int recipeId;

  const ViewRecipe(this.recipeId, {super.key});

  @override
  State<ViewRecipe> createState() => _ViewRecipeState();
}

class _ViewRecipeState extends State<ViewRecipe> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();

  late Future<Map<String, dynamic>> _currentRecipe;
  bool _isModified = false;

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _currentRecipe = _fetchRecipeDetails(widget.recipeId);
  }

  Future<Map<String, dynamic>> _fetchRecipeDetails(int recipeId) async {
    final result = await DatabaseHelper.instance.getRecipeForId(recipeId);
    if (result.isNotEmpty) {
      return result.first;
    } else {
      throw Exception(AppStrings.messageRecipeNotFound);
    }
  }

  void _launchEditRecipeAndAwait() async {
    _isModified = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddRecipe(widget.recipeId)),
    );
    setState(() {
      if (_isModified) {
        _currentRecipe = _fetchRecipeDetails(widget.recipeId);
      }
    });
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogBuilder(
            title: AppStrings.titleDialogConfirmation,
            message: AppStrings.messageRecipeDelete,
            positiveAction: () {
              Navigator.of(context).pop();
              _deleteRecipeWithId(widget.recipeId);
            },
            negativeAction: () {
              Navigator.of(context).pop();
            });
      },
    );
  }

  Future<void> _deleteRecipeWithId(int recipeId) async {
    final result = await DatabaseHelper.instance.deleteRecipeWithId(recipeId);
    if (mounted && result > 0) {
      _isModified = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.messageRecipeDeleteSuccess)),
      );
      Navigator.of(context).pop(_isModified);
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
          title: const Text(AppStrings.titleViewRecipe),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _launchEditRecipeAndAwait();
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: () {
                _showDeleteDialog();
              },
            )
          ],
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _currentRecipe,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('${AppStrings.labelPrefixError}: ${snapshot.error}')
              );
            } else if (snapshot.hasData) {
              final recipe = snapshot.data!;
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
                        content: recipe[DatabaseHelper.columnTitle],
                        validator: (value) => value == null || value.isEmpty
                            ? AppStrings.labelRecipeName
                            : null,
                      ),
                      _buildTextFormField(
                        controller: _categoryController,
                        labelText: AppStrings.labelCategory,
                        content: recipe[DatabaseHelper.columnCategory],
                        validator: (value) =>
                        value == null || value.isEmpty
                            ? AppStrings.labelCategoryPrompt
                            : null,
                      ),
                      _buildTextFormField(
                        controller: _descriptionController,
                        labelText: AppStrings.labelDescription,
                        content: recipe[DatabaseHelper.columnDescription],
                        validator: (value) => value == null || value.isEmpty
                            ? AppStrings.labelDescriptionPrompt
                            : null,
                      ),
                      _buildTextFormField(
                        controller: _ingredientsController,
                        labelText: AppStrings.labelIngredients,
                        content: recipe[DatabaseHelper.columnIngredients],
                        validator: (value) => value == null || value.isEmpty
                            ? AppStrings.labelIngredientsPrompt
                            : null,
                      ),
                      _buildTextFormField(
                        controller: _instructionsController,
                        labelText: AppStrings.labelSteps,
                        content: recipe[DatabaseHelper.columnInstructions],
                        validator: (value) => value == null || value.isEmpty
                            ? AppStrings.labelStepsPrompt
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const Center(
                  child: Text(AppStrings.messageRecipeNotFound));
            }
          },
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String content,
    required String? Function(String?) validator,
  }) {
    controller.text = content;
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        readOnly: true,
        controller: controller,
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
}
