import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:myapp/models/user.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const String dbName = "mytrain.db";
  static const int dbVersion = 1;
  static const String usersTable = "users";

  // Singleton instance
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  Database? _database;

  // Getter to return existing connection or open a new one
  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize and return database connection
  Future<Database> _initDatabase() async {
    return await openDatabase(
      dbName,
      version: dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS $usersTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fullName TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Called once during app startup in main.dart
  Future<void> initDB() async {
    final db = await database;
    print("Database initialized successfully: ${db.path}");
  }

  // Hash password helper
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Signup
  Future<bool> signup(Map<String, dynamic> user) async {
    try {
      final db = await database;

      final hashedPassword = hashPassword(user['password']);

      final userData = {
        'fullName': user['fullName'],
        'email': user['email'],
        'password': hashedPassword,
      };

      await db.insert(
        usersTable,
        userData,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      print("User signed up successfully");
      return true;
    } catch (e) {
      print("Error signing up user: $e");
      return false;
    }
  }

  // Login
  Future<User?> login(String email, String password) async {
    try {
      final db = await database;

      final hashedPassword = hashPassword(password);

      final result = await db.query(
        usersTable,
        where: 'email = ? AND password = ?',
        whereArgs: [email, hashedPassword],
        limit: 1,
      );

      if (result.isNotEmpty) {
        return User.fromMap(result.first);
      }

      return null;
    } catch (e) {
      print("Error logging in user: $e");
      return null;
    }
  }

  // Delete user
  Future<bool> deleteUser(int userId) async {
    try {
      final db = await database;

      final rowsDeleted = await db.delete(
        usersTable,
        where: 'id = ?',
        whereArgs: [userId],
      );

      return rowsDeleted > 0;
    } catch (e) {
      print("Error deleting user: $e");
      return false;
    }
  }
}
