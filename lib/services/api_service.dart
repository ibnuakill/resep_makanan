import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/recipe.dart';

/// TheMealDB free tier (tanpa API key).
class ApiService {
  const ApiService();
  static const _base = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Recipe>> byCategory(String category) async {
    final meals = await _get('/filter.php', {'c': category});
    return meals.map(Recipe.fromSummary).toList();
  }

  Future<List<String>> categories() async {
    final meals = await _get('/list.php', {'c': 'list'});
    return meals.map((m) => m['strCategory'] as String).toList();
  }

  Future<List<Recipe>> byArea(String area) async {
    final meals = await _get('/filter.php', {'a': area});
    return meals.map(Recipe.fromSummary).toList();
  }

  Future<List<String>> areas() async {
    final meals = await _get('/list.php', {'a': 'list'});
    return meals.map((m) => m['strArea'] as String).toList();
  }

  Future<Recipe?> detail(String id) async {
    final meals = await _get('/lookup.php', {'i': id});
    if (meals.isEmpty) return null;
    return Recipe.fromDetail(meals.first);
  }

  Future<List<Recipe>> search(String query) async {
    final meals = await _get('/search.php', {'s': query});
    return meals.map(Recipe.fromSummary).toList();
  }

  /// Ambil resep random untuk "Rekomendasi hari ini".
  Future<Recipe?> random() async {
    final meals = await _get('/random.php', {});
    if (meals.isEmpty) return null;
    return Recipe.fromDetail(meals.first);
  }

  Future<List<Map<String, dynamic>>> _get(
    String path,
    Map<String, String> query,
  ) async {
    final uri = Uri.parse('$_base$path').replace(queryParameters: query);
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode} untuk $uri');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final meals = body['meals'];
    if (meals == null) return const [];
    return (meals as List).cast<Map<String, dynamic>>();
  }
}
