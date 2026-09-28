import '../models/recipe.dart';
import 'api_service.dart';
import 'local_recipes.dart';

/// Gabung data lokal (Indonesia, lengkap) + TheMealDB (internasional).
/// Pencarian: lokal dulu (selalu ada), lalu API — API gagal pun hasil lokal tetap keluar.
class RecipeRepository {
  final ApiService api;
  final LocalRecipes local;
  const RecipeRepository({required this.api, required this.local});

  Future<List<Recipe>> search(String query) async {
    final localResults = await local.search(query);
    List<Recipe> remote = [];
    try {
      remote = await api.search(query);
    } catch (_) {
      // API mati: hasil lokal tetap dipakai.
    }
    // Hindari duplikat berdasarkan nama.
    final seen = localResults.map((r) => r.name.toLowerCase()).toSet();
    final merged = [...localResults];
    for (final r in remote) {
      if (seen.add(r.name.toLowerCase())) merged.add(r);
    }
    return merged;
  }

  Future<List<Recipe>> byCategory(String category) async {
    if (category == 'Indonesia') return local.all();
    return api.byCategory(category);
  }

  /// Kategori API + "Indonesia" selalu di depan.
  Future<List<String>> categories() async {
    var remote = <String>[];
    try {
      remote = await api.categories();
    } catch (_) {}
    return ['Indonesia', ...remote];
  }

  Future<List<Recipe>> byArea(String area) async {
    if (area == 'Indonesia' || area == 'Indonesian') return local.all();
    return api.byArea(area);
  }

  Future<List<String>> areas() async {
    var remote = <String>[];
    try {
      remote = await api.areas();
    } catch (_) {}
    return ['Indonesia', ...remote];
  }

  Future<Recipe?> detail(String id) async {
    if (id.startsWith('local-')) return local.byId(id);
    return api.detail(id);
  }

  Future<Recipe?> random() async {
    // Campur: kadang rekomendasi lokal, kadang internasional.
    final lokal = await local.all();
    if (DateTime.now().second % 3 == 0 && lokal.isNotEmpty) {
      return lokal[DateTime.now().millisecondsSinceEpoch % lokal.length];
    }
    try {
      final r = await api.random();
      if (r != null) return r;
    } catch (_) {}
    if (lokal.isEmpty) return null;
    return lokal[DateTime.now().millisecondsSinceEpoch % lokal.length];
  }

  Future<List<Recipe>> byIds(List<String> ids) async {
    final out = <Recipe>[];
    for (final id in ids) {
      final r = await detail(id);
      if (r != null) out.add(r);
    }
    return out;
  }
}
