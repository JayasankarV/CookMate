import 'package:cook_mate/add_recipe.dart';
import 'package:cook_mate/helper/DatabaseHelper.dart';
import 'package:cook_mate/resources/strings.dart';
import 'package:flutter/material.dart';

class ViewRecipe extends StatefulWidget {
  final int recipeId;

  const ViewRecipe(this.recipeId, {super.key});

  @override
  State<ViewRecipe> createState() => _ViewRecipeState();
}

class _ViewRecipeState extends State<ViewRecipe> {
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
                        minLines: 1,
                        maxLines: 2,
                        validator: (value) => value == null || value.isEmpty
                            ? AppStrings.labelRecipeName
                            : null,
                      ),
                      _buildTextFormField(
                        controller: _descriptionController,
                        labelText: AppStrings.labelDescription,
                        content: recipe[DatabaseHelper.columnDescription],
                        minLines: 1,
                        maxLines: 3,
                        validator: (value) => value == null || value.isEmpty
                            ? AppStrings.labelDescriptionPrompt
                            : null,
                      ),
                      _buildTextFormField(
                        controller: _ingredientsController,
                        labelText: AppStrings.labelIngredients,
                        content: recipe[DatabaseHelper.columnIngredients],
                        minLines: 3,
                        maxLines: 10,
                        validator: (value) => value == null || value.isEmpty
                            ? AppStrings.labelIngredientsPrompt
                            : null,
                      ),
                      _buildTextFormField(
                        controller: _instructionsController,
                        labelText: AppStrings.labelSteps,
                        content: recipe[DatabaseHelper.columnInstructions],
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
    required int minLines,
    required int maxLines,
    required String? Function(String?) validator,
  }) {
    controller.text = content;
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        readOnly: true,
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
}
