import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  AppSettings._();

  static final ValueNotifier<bool> darkModeNotifier = ValueNotifier<bool>(
    false,
  );

  static final ValueNotifier<bool> notificationsNotifier = ValueNotifier<bool>(
    true,
  );

  static const String _darkModeKey = 'roadcare_dark_mode';
  static const String _notificationsKey = 'roadcare_notifications';

  // =========================================================
  // LOAD SETTINGS
  // =========================================================

  static Future<void> loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    darkModeNotifier.value = prefs.getBool(_darkModeKey) ?? false;

    notificationsNotifier.value = prefs.getBool(_notificationsKey) ?? true;
  }

  // =========================================================
  // DARK MODE
  // =========================================================

  static Future<void> setDarkMode(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_darkModeKey, value);

    darkModeNotifier.value = value;
  }

  // =========================================================
  // NOTIFICATIONS
  // =========================================================

  static Future<void> setNotifications(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_notificationsKey, value);

    notificationsNotifier.value = value;
  }

  // =========================================================
  // RESET SETTINGS
  // =========================================================

  static Future<void> resetSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_darkModeKey, false);

    await prefs.setBool(_notificationsKey, true);

    darkModeNotifier.value = false;

    notificationsNotifier.value = true;
  }
}
