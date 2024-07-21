import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "cookMateDatabase.db";
  static const _databaseVersion = 2;

  static const recipeTable = "Recipes";

  static const columnId = '_id';
  static const columnTitle = 'title';
  static const columnCategory = 'category';
  static const columnDescription = 'description';
  static const columnIngredients = 'ingredients';
  static const columnInstructions = 'instructions';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(
        await getDatabasesPath(),
        _databaseName
    );
    return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $recipeTable (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnTitle TEXT NOT NULL,
            $columnDescription TEXT NOT NULL,
            $columnIngredients TEXT NOT NULL,
            $columnInstructions TEXT NOT NULL
          )
          ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
          ALTER TABLE $recipeTable ADD COLUMN $columnCategory TEXT
          ''');
    }
  }

  /*TODO: Need to use Recipe model instead of map*/
  Future<int> insertOrUpdate(Map<String, dynamic> row, int recipeId) async {
    Database db = await instance.database;
    bool exists = await doesRecipeIdExist(recipeId);
    if (exists) {
      return await db.update(
          recipeTable,
          row,
          where: '${DatabaseHelper.columnId} = ?',
          whereArgs: [recipeId]
      );
    } else {
      return await db.insert(recipeTable, row);
    }
  }

  Future<bool> doesRecipeIdExist(int recipeId) async {
    final result = await getRecipeForId(recipeId);
    return result.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getRecipes() async {
    Database db = await instance.database;
    return await db.query(recipeTable);
  }

  Future<List<Map<String, Object?>>> getRecipeForId(int recipeId) async {
    Database db = await instance.database;
    final result = await db.query(
        recipeTable,
        where: '${DatabaseHelper.columnId} = ?',
        whereArgs: [recipeId],
        limit: 1
    );
    return result;
  }

  Future<List<String>> getFilters() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT $columnCategory
      FROM $recipeTable
    ''');
    return List<String>.from(maps.map((map) => map[columnCategory]));
  }

  Future<int> deleteRecipeWithId(int recipeId) async {
    Database db = await instance.database;
    return await db.delete(
        recipeTable,
        where: '${DatabaseHelper.columnId} = ?',
        whereArgs: [recipeId]
    );
  }

  Future<int> deleteAllRecipes() async {
    Database db = await instance.database;
    return await db.delete(recipeTable);
  }

}