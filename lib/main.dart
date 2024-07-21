import 'package:cook_mate/add_recipe.dart';
import 'package:cook_mate/helper/DatabaseHelper.dart';
import 'package:cook_mate/helper/DialogHelper.dart';
import 'package:cook_mate/resources/strings.dart';
import 'package:cook_mate/view_recipe.dart';
import 'package:flutter/material.dart';

import 'custom/SearchField.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
        seedColor: Colors.deepPurple, brightness: Brightness.light);

    final themeData = ThemeData(
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );

    return MaterialApp(
      title: AppStrings.appName,
      theme: themeData,
      home: const MyHomePage(title: AppStrings.titleHomeRecipe),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _recipes = [];
  List<Map<String, dynamic>> _filteredRecipes = [];
  bool _isLoading = true;

  void _launchAddRecipeAndAwait() async {
    final isUpdated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddRecipe(-1)),
    );
    setState(() {
      if (isUpdated) {
        _fetchRecipes();
      }
    });
  }

  void _launchRecipeDetailsAndAwait(int recipeId) async {
    final isUpdated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViewRecipe(recipeId)),
    );
    setState(() {
      if (isUpdated) {
        _fetchRecipes();
      }
    });
  }

  void _showDeleteAllDialog() {
    if (_recipes.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogBuilder(
              title: AppStrings.titleDialogConfirmation,
              message: AppStrings.messageRecipeDeleteAll,
              positiveAction: () {
                Navigator.of(context).pop();
                _deleteAllRecipes();
              },
              negativeAction: () {
                Navigator.of(context).pop();
              });
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.messageDeleteAllEmpty)),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    _isLoading = true;
    final recipes = await DatabaseHelper.instance.getRecipes();
    setState(() {
      _recipes = recipes;
      _filteredRecipes = recipes;
      _isLoading = false;
    });
  }

  Future<void> _deleteAllRecipes() async {
    _isLoading = true;
    final result = await DatabaseHelper.instance.deleteAllRecipes();
    if (mounted && result > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.messageRecipeDeleteAllSuccess)),
      );
      _fetchRecipes();
    }
  }

  void _filterRecipes(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredRecipes = _recipes;
      });
    } else {
      setState(() {
        _filteredRecipes = _recipes
            .where((recipe) => recipe[DatabaseHelper.columnTitle]
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(
              onPressed: (_showDeleteAllDialog),
              icon: const Icon(Icons.filter_alt)),
          IconButton(
              onPressed: (_showDeleteAllDialog),
              icon: const Icon(Icons.delete_forever))
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SearchField(onChanged: _filterRecipes),
                ),
                _filteredRecipes.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: _filteredRecipes.length,
                          itemBuilder: (context, index) {
                            final recipe = _filteredRecipes[index];
                            return _buildRecipeCard(
                                title: recipe[DatabaseHelper.columnTitle],
                                description:
                                    recipe[DatabaseHelper.columnDescription],
                                onTap: () {
                                  _launchRecipeDetailsAndAwait(
                                      recipe[DatabaseHelper.columnId]);
                                });
                          },
                        ),
                      )
                    : const Expanded(
                        child: Center(
                        child: Text(
                          AppStrings.messageAddResumeToContinue,
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _launchAddRecipeAndAwait,
        tooltip: AppStrings.titleAddRecipe,
        child: const Icon(Icons.add),
      ),
    );
  }
}

Widget _buildRecipeCard(
    {required String title,
    required String description,
    required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16.0,
          ),
        ]),
      ),
    ),
  );
}
