import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';
import '../models/user.dart';

class AuthService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // =========================================================
  // PASSWORD HASH
  // =========================================================

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);

    return digest.toString();
  }

  // =========================================================
  // REGISTER
  // =========================================================

  Future<RoadUser?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final int userId = await _databaseHelper.registerUser(
        username: name,
        email: email,
        password: password,
      );

      if (userId <= 0) {
        return null;
      }

      return RoadUser(
        id: userId,
        name: name.trim(),
        email: email.trim().toLowerCase(),
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================================================
  // LOGIN
  // =========================================================

  Future<RoadUser?> login({
    required String email,
    required String password,
  }) async {
    try {
      final db = await _databaseHelper.database;

      final String cleanEmail = email.trim().toLowerCase();

      // -------------------------------------------------------
      // Get user using email only.
      //
      // We compare the password below so that both:
      // 1. Existing plain-text records
      // 2. Hashed records
      //
      // can work.
      // -------------------------------------------------------

      final List<Map<String, dynamic>> results = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [cleanEmail],
        limit: 1,
      );

      if (results.isEmpty) {
        return null;
      }

      final Map<String, dynamic> userMap = Map<String, dynamic>.from(
        results.first,
      );

      final String storedPassword = (userMap['password'] ?? '').toString();

      final String enteredPassword = password;

      final String hashedEnteredPassword = _hashPassword(password);

      // -------------------------------------------------------
      // SUPPORT BOTH PASSWORD FORMATS
      // -------------------------------------------------------

      final bool passwordMatches =
          storedPassword == enteredPassword ||
          storedPassword == hashedEnteredPassword;

      if (!passwordMatches) {
        return null;
      }

      // -------------------------------------------------------
      // USER ID
      // -------------------------------------------------------

      final dynamic rawId = userMap['id'];

      final int? userId = rawId is int ? rawId : int.tryParse(rawId.toString());

      if (userId == null || userId <= 0) {
        return null;
      }

      // -------------------------------------------------------
      // USER NAME
      // -------------------------------------------------------

      final String userName = (userMap['username'] ?? userMap['name'] ?? '')
          .toString();

      final String userEmail = (userMap['email'] ?? '').toString();

      // -------------------------------------------------------
      // SAVE LOGIN SESSION
      // -------------------------------------------------------

      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setInt('roadcare_user_id', userId);

      await prefs.setString('roadcare_user_name', userName);

      await prefs.setString('roadcare_user_email', userEmail);

      await prefs.setBool('roadcare_logged_in', true);

      // -------------------------------------------------------
      // RETURN USER
      // -------------------------------------------------------

      return RoadUser(id: userId, name: userName, email: userEmail);
    } catch (e) {
      rethrow;
    }
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('roadcare_user_id');
    await prefs.remove('roadcare_user_name');
    await prefs.remove('roadcare_user_email');

    await prefs.setBool('roadcare_logged_in', false);

    // Clear camera recovery session
    await prefs.remove('roadcare_pending_camera');
    await prefs.remove('roadcare_pending_user_id');
  }

  // =========================================================
  // CHECK LOGIN STATUS
  // =========================================================

  Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool('roadcare_logged_in') ?? false;
  }

  // =========================================================
  // GET CURRENT USER ID
  // =========================================================

  Future<int?> getCurrentUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getInt('roadcare_user_id');
  }

  // =========================================================
  // GET CURRENT USER NAME
  // =========================================================

  Future<String?> getCurrentUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString('roadcare_user_name');
  }

  // =========================================================
  // GET CURRENT USER EMAIL
  // =========================================================

  Future<String?> getCurrentUserEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString('roadcare_user_email');
  }
}
