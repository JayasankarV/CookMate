import 'package:cook_mate/add_recipe.dart';
import 'package:cook_mate/helper/DatabaseHelper.dart';
import 'package:cook_mate/resources/strings.dart';
import 'package:cook_mate/view_recipe.dart';
import 'package:flutter/material.dart';

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
      home: const MyHomePage(title: AppStrings.appName),
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
  bool _isLoading = true;

  void _launchAddRecipeAndAwait() async {
    final isUpdated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddRecipe()),
    );
    setState(() {
      if (isUpdated) {
        _fetchRecipes();
      }
    });
  }

  void _viewRecipeDetails() {
    setState(() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ViewRecipe()),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    final recipes = await DatabaseHelper.instance.getRecipes();
    setState(() {
      _recipes = recipes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _recipes.length,
              itemBuilder: (context, index) {
                final recipe = _recipes[index];
                return _buildRecipeCard(
                    title: recipe[DatabaseHelper.columnTitle],
                    description: recipe[DatabaseHelper.columnDescription],
                    onTap: () {
                      _viewRecipeDetails();
                    });
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _launchAddRecipeAndAwait,
        tooltip: AppStrings.titleAddRecipe,
        child: const Icon(Icons.add),
      ),
    );
  }
}

Widget _buildRecipeCard({
  required String title,
  required String description,
  required VoidCallback onTap
}) {
  return GestureDetector(
    onTap: onTap,
    child: Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
