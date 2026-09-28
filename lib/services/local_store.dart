import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/recipe.dart';

/// Favorit, rating, dan riwayat — semua lokal di device.
class LocalStore {
  const LocalStore();
  static const _kFav = 'fav_ids';
  static const _kRatings = 'ratings';
  static const _kHistory = 'history_ids';
  static const _kLanguage = 'app_language';

  /// Mendapatkan kode bahasa ('id' atau 'en'). Default 'id'.
  Future<String> getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kLanguage) ?? 'id';
  }

  /// Menyimpan preferensi bahasa ('id' atau 'en').
  Future<void> setLanguageCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguage, code);
  }

  Future<List<Recipe>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kFav) ?? [];
    final list = <Recipe>[];
    for (final s in raw) {
      try {
        // Fallback for old simple IDs if they exist. (Old ID won't parse as JSON map)
        if (!s.startsWith('{')) continue;
        list.add(Recipe.fromJson(jsonDecode(s)));
      } catch (_) {}
    }
    return list;
  }

  Future<Set<String>> favoriteIds() async {
    final favs = await getFavorites();
    return favs.map((e) => e.id).toSet();
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = await getFavorites();
    final idx = favs.indexWhere((e) => e.id == recipe.id);
    if (idx >= 0) {
      favs.removeAt(idx);
    } else {
      favs.add(recipe);
    }
    final raw = favs.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_kFav, raw);
  }

  /// id → rating 1..5
  Future<Map<String, int>> ratings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kRatings);
    if (raw == null) return {};
    return Map<String, int>.from(jsonDecode(raw) as Map);
  }

  Future<void> setRating(String id, int stars) async {
    final prefs = await SharedPreferences.getInstance();
    final map = await ratings();
    if (stars <= 0) {
      map.remove(id);
    } else {
      map[id] = stars;
    }
    await prefs.setString(_kRatings, jsonEncode(map));
  }

  /// id paling baru dilihat di depan.
  Future<List<String>> history() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kHistory) ?? [];
  }

  Future<void> pushHistory(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = (prefs.getStringList(_kHistory) ?? [])
      ..remove(id)
      ..insert(0, id);
    await prefs.setStringList(_kHistory, list.take(50).toList());
  }
}
