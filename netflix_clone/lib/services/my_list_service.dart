import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie.dart';

class MyListService {
  static const String _myListKey = 'my_list';

  static List<Movie> _myList = [];

  // Notifies My List screen whenever the list changes.
  static final ValueNotifier<int> listVersion = ValueNotifier<int>(0);

  static List<Movie> get myList {
    return List.unmodifiable(_myList);
  }

  // ============================================================
  // LOAD
  // ============================================================

  static Future<void> loadMyList() async {
    final prefs = await SharedPreferences.getInstance();

    final savedMovies = prefs.getStringList(_myListKey);

    if (savedMovies == null) {
      _myList = [];
      listVersion.value++;
      return;
    }

    _myList = savedMovies
        .map(
          (movieJson) =>
              Movie.fromJson(jsonDecode(movieJson) as Map<String, dynamic>),
        )
        .toList();

    listVersion.value++;
  }

  // ============================================================
  // CHECK
  // ============================================================

  static bool isInMyList(Movie movie) {
    return _myList.any((item) => item.title == movie.title);
  }

  // ============================================================
  // ADD
  // ============================================================

  static Future<void> addMovie(Movie movie) async {
    if (isInMyList(movie)) {
      return;
    }

    _myList.add(movie);

    await _saveMyList();

    // Refresh all listening screens.
    listVersion.value++;
  }

  // ============================================================
  // REMOVE
  // ============================================================

  static Future<void> removeMovie(Movie movie) async {
    _myList.removeWhere((item) => item.title == movie.title);

    await _saveMyList();

    // Refresh all listening screens.
    listVersion.value++;
  }

  // ============================================================
  // TOGGLE
  // ============================================================

  static Future<void> toggleMovie(Movie movie) async {
    if (isInMyList(movie)) {
      await removeMovie(movie);
    } else {
      await addMovie(movie);
    }
  }

  // ============================================================
  // SAVE
  // ============================================================

  static Future<void> _saveMyList() async {
    final prefs = await SharedPreferences.getInstance();

    final savedMovies = _myList
        .map((movie) => jsonEncode(movie.toJson()))
        .toList();

    await prefs.setStringList(_myListKey, savedMovies);
  }

  // ============================================================
  // CLEAR
  // ============================================================

  static Future<void> clearMyList() async {
    _myList.clear();

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_myListKey);

    listVersion.value++;
  }
}
