import '../database/database_constants.dart';
import '../database/database_helper.dart';
import '../models/user.dart';

class UserRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // =========================================================
  // CREATE USER
  // =========================================================

  Future<int> createUser(RoadUser user) async {
    final db = await _databaseHelper.database;

    return await db.insert(DatabaseConstants.usersTable, user.toMap());
  }

  // =========================================================
  // FIND USER BY EMAIL
  // =========================================================

  Future<RoadUser?> getUserByEmail(String email) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      DatabaseConstants.usersTable,
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return RoadUser.fromMap(result.first);
  }

  // =========================================================
  // GET USER BY ID
  // =========================================================

  Future<RoadUser?> getUserById(int userId) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      DatabaseConstants.usersTable,
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return RoadUser.fromMap(result.first);
  }

  // =========================================================
  // LOGIN
  // =========================================================

  Future<RoadUser?> login(String email, String passwordHash) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      DatabaseConstants.usersTable,
      where: 'email = ? AND password_hash = ?',
      whereArgs: [email, passwordHash],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return RoadUser.fromMap(result.first);
  }

  // =========================================================
  // UPDATE USER NAME
  // =========================================================

  Future<int> updateUserName(int userId, String newName) async {
    final db = await _databaseHelper.database;

    return await db.update(
      DatabaseConstants.usersTable,
      {'username': newName},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // =========================================================
  // UPDATE USER
  // =========================================================

  Future<int> updateUser({
    required int userId,
    required String name,
    required String email,
  }) async {
    final db = await _databaseHelper.database;

    return await db.update(
      DatabaseConstants.usersTable,
      {'username': name, 'email': email},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
