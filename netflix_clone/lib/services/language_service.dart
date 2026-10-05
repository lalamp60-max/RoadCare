import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'app_language';

  static final ValueNotifier<String> language = ValueNotifier<String>(
    'English',
  );

  static Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    final savedLanguage = prefs.getString(_languageKey);

    language.value = savedLanguage ?? 'English';
  }

  static bool get isTelugu {
    return language.value == 'Telugu';
  }

  static bool get isEnglish {
    return language.value == 'English';
  }

  static Future<void> setLanguage(String newLanguage) async {
    language.value = newLanguage;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_languageKey, newLanguage);
  }

  static String text(String english, String telugu) {
    return isTelugu ? telugu : english;
  }
}
