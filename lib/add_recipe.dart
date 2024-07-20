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
        title: const Text('Add Recipe'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(onPressed: (_saveRecipe), icon: const Icon(Icons.save))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildTextFormField(
                controller: _titleController,
                labelText: 'Recipe Name',
                minLines: 1,
                maxLines: 2,
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter the recipe name"
                    : null,
              ),
              _buildTextFormField(
                controller: _descriptionController,
                labelText: 'Description',
                minLines: 1,
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter the description"
                    : null,
              ),
              _buildTextFormField(
                controller: _ingredientsController,
                labelText: 'Ingredients',
                minLines: 3,
                maxLines: 10,
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter the ingredients"
                    : null,
              ),
              _buildTextFormField(
                controller: _instructionsController,
                labelText: 'Steps',
                minLines: 3,
                maxLines: 10,
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter the steps to prepare"
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
      _saveRecipeIntoDatabase();
    }
  }

  Future<void> _saveRecipeIntoDatabase() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recipe saved successfully!')),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pop();
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
