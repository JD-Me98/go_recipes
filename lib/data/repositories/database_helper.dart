import 'package:go_recipes/features/authentication/models/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static const String ID = 'id';
  static const String EMAIL = 'email';
  static const String USERNAME = 'username';
  static const String PASSWORD = 'password'; 
  static const String PHOTO = 'photo';
  static const String AUTHMETHOD = 'authMethod';
  static const String TABLENAME = 'users';
  static const String DB_NAME = 'gorecipes.db';

  static const String FAVORITETABLE = 'favorites';
  static const String F_ID = 'id';
  static const String U_ID = 'user_id';
  static const String R_ID = 'recipe_id';

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), DB_NAME);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE $TABLENAME($ID INTEGER PRIMARY KEY AUTOINCREMENT, $USERNAME TEXT, $EMAIL TEXT, $PASSWORD TEXT, $PHOTO TEXT, $AUTHMETHOD TEXT)'
        );
        await db.execute(
          'CREATE TABLE $FAVORITETABLE($F_ID INTEGER PRIMARY KEY AUTOINCREMENT, $U_ID INTEGER, $R_ID TEXT, '
          'FOREIGN KEY($U_ID) REFERENCES $TABLENAME($ID) ON DELETE CASCADE)'
        );
      },
    );
  }

  Future<void> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    await db.insert(
      TABLENAME,
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateUser(Map<String, dynamic> user) async {
    final db = await database;
    final id = user['id'];

    if (id == null) {
      throw Exception("User ID is required for update.");
    }

    await db.update(
      'users', // Replace with your table name
      user,
      where: 'id = ?', // Ensures the update targets the correct record
      whereArgs: [id],
    );

  }


 Future<void> insertFavorite(Map<String, dynamic> favorite) async {
    final db = await database; // Your database reference
    await db.insert(
      FAVORITETABLE, // Replace with your table name
      favorite,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<User>> getUsers() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      TABLENAME,
      columns: [ID, USERNAME, EMAIL, PASSWORD, PHOTO],
    );

    return maps.isNotEmpty
        ? maps.map((map) => User.fromMap(map)).toList()
        : [];
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      TABLENAME,
      where: '$EMAIL = ? AND $PASSWORD = ?',
      whereArgs: [email, password],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      TABLENAME,
      where: '$ID = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }


  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
