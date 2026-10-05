import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _userIdKey = 'logged_in_user_id';
  static const String _userNameKey = 'logged_in_user_name';

  // =========================================================
  // SAVE LOGIN
  // =========================================================

  static Future<void> saveUserSession(int userId, {String? userName}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_userIdKey, userId);

    if (userName != null && userName.trim().isNotEmpty) {
      await prefs.setString(_userNameKey, userName.trim());
    }
  }

  // =========================================================
  // GET LOGIN USER
  // =========================================================

  static Future<int?> getLoggedInUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getInt(_userIdKey);
  }

  // =========================================================
  // GET LOGIN USER NAME
  // =========================================================

  static Future<String?> getLoggedInUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_userNameKey);
  }

  // =========================================================
  // UPDATE SESSION USER NAME
  // =========================================================

  static Future<void> updateUserName(String userName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(_userNameKey, userName.trim());
  }

  // =========================================================
  // CHECK LOGIN
  // =========================================================

  static Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.containsKey(_userIdKey);
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  static Future<void> clearSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
  }
}
