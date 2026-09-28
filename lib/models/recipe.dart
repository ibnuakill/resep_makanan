/// Ringkas untuk list; detail lengkap diisi saat lookup.
/// id berprefix sumbernya: "local-..." (aset) atau angka TheMealDB.
class Recipe {
  final String id;
  final String name;
  final String thumbnail;
  final String? category;
  final String? area;
  final String? instructions;
  final List<Ingredient> ingredients;

  bool get isLocal => id.startsWith('local-');

  const Recipe({
    required this.id,
    required this.name,
    required this.thumbnail,
    this.category,
    this.area,
    this.instructions,
    this.ingredients = const [],
  });

  factory Recipe.fromSummary(Map<String, dynamic> json) => Recipe(
        id: json['idMeal'] as String,
        name: json['strMeal'] as String,
        thumbnail: json['strMealThumb'] as String? ?? '',
        area: json['strArea'] as String?,
      );

  /// Dipakai untuk TheMealDB detail, lookup lokal, dan pencarian case-insensitive.
  factory Recipe.fromDetail(Map<String, dynamic> json) {
    final ingredients = <Ingredient>[];
    for (var i = 1; i <= 20; i++) {
      final name = (json['strIngredient$i'] as String?)?.trim();
      if (name == null || name.isEmpty) continue;
      ingredients.add(Ingredient(
        name: name,
        measure: (json['strMeasure$i'] as String?)?.trim() ?? '',
      ));
    }
    return Recipe(
      id: json['idMeal'] as String,
      name: json['strMeal'] as String,
      thumbnail: json['strMealThumb'] as String? ?? '',
      category: json['strCategory'] as String?,
      area: json['strArea'] as String?,
      instructions: json['strInstructions'] as String?,
      ingredients: ingredients,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'thumbnail': thumbnail,
      'category': category,
      'area': area,
      'instructions': instructions,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      name: json['name'] as String,
      thumbnail: json['thumbnail'] as String,
      category: json['category'] as String?,
      area: json['area'] as String?,
      instructions: json['instructions'] as String?,
      ingredients: (json['ingredients'] as List?)
              ?.map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Ingredient {
  final String name;
  final String measure;
  const Ingredient({required this.name, required this.measure});

  Map<String, dynamic> toJson() => {'name': name, 'measure': measure};
  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        name: json['name'] as String,
        measure: json['measure'] as String,
      );
}
