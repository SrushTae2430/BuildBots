import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;
    String path = join(await getDatabasesPath(), 'users.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute("""
          CREATE TABLE users(
            email TEXT PRIMARY KEY,
            age INTEGER,
            language TEXT,
            gender TEXT,
            height INTEGER,
            weight INTEGER,
            lifestyle TEXT,
            smoking TEXT,
            alcohol TEXT,
            exercise TEXT,
            diet TEXT,
            sleep TEXT,
            stress TEXT,
            medical_conditions TEXT,
            family_history TEXT
          )
        """);
      },
    );
    return _db!;
  }

  static Future<void> insertUser(Map<String, dynamic> user) async {
    final db = await getDatabase();
    await db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}