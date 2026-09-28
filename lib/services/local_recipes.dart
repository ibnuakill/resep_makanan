import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/recipe.dart';

/// Resep Indonesia dari aset — jaminan "soto betawi" selalu ketemu,
/// termasuk offline.
class LocalRecipes {
  LocalRecipes();
  List<Recipe>? _cache;

  Future<List<Recipe>> all() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/recipes_local.json');
    final list = jsonDecode(raw) as List<dynamic>;
    _cache = list
        .map((e) => Recipe.fromDetail(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  Future<Recipe?> byId(String id) async {
    final list = await all();
    for (final r in list) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// Cari di nama + bahan, tanpa memedulikan huruf besar/kecil.
  Future<List<Recipe>> search(String query) async {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return const [];
    final list = await all();
    return list.where((r) {
      if (r.name.toLowerCase().contains(q)) return true;
      return r.ingredients.any((i) => i.name.toLowerCase().contains(q));
    }).toList();
  }
}
