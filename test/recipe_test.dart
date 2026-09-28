import 'package:flutter_test/flutter_test.dart';
import 'package:resep_makanan/models/recipe.dart';
import 'package:resep_makanan/services/local_recipes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Recipe.fromDetail meratakan strIngredient1..20', () {
    final json = <String, dynamic>{
      'idMeal': '1',
      'strMeal': 'Nasi Goreng',
      'strMealThumb': 'https://example.com/x.jpg',
      'strCategory': 'Chicken',
      'strArea': 'Indonesian',
      'strInstructions': 'Masak.',
      'strIngredient1': 'Rice',
      'strMeasure1': '2 cups',
      'strIngredient2': '',
      'strIngredient3': 'Egg',
      'strMeasure3': '1',
      for (var i = 4; i <= 20; i++) 'strIngredient$i': null,
    };

    final recipe = Recipe.fromDetail(json);

    expect(recipe.id, '1');
    expect(recipe.ingredients, hasLength(2));
    expect(recipe.ingredients[0].name, 'Rice');
    expect(recipe.ingredients[0].measure, '2 cups');
    expect(recipe.ingredients[1].name, 'Egg');
    expect(recipe.category, 'Chicken');
  });

  test('Recipe.fromSummary tidak butuh field detail', () {
    final recipe = Recipe.fromSummary({
      'idMeal': '52772',
      'strMeal': 'Teriyaki',
      'strMealThumb': 'https://example.com/t.jpg',
      'strArea': 'Japanese',
    });
    expect(recipe.ingredients, isEmpty);
    expect(recipe.instructions, isNull);
  });

  test('resep lokal punya "Soto Betawi" dan bisa dicari', () async {
    final local = LocalRecipes();
    final all = await local.all();
    expect(all, isNotEmpty);
    expect(all.any((r) => r.name == 'Soto Betawi'), isTrue);

    final found = await local.search('soto betawi');
    expect(found, isNotEmpty);
    expect(found.first.name, 'Soto Betawi');
    expect(found.first.isLocal, isTrue);
    expect(found.first.ingredients, isNotEmpty);
  });

  test('Recipe.toJson dan fromJson saling simetris', () {
    final original = const Recipe(
      id: 'local-999',
      name: 'Ayam Penyet',
      thumbnail: 'thumb.jpg',
      category: 'Indonesian',
      instructions: 'Goreng lalu penyet.',
      ingredients: [
        Ingredient(name: 'Ayam', measure: '1 Ekor'),
        Ingredient(name: 'Sambal', measure: 'Secukupnya'),
      ]
    );
    
    final serialized = original.toJson();
    final deserialized = Recipe.fromJson(serialized);
    
    expect(deserialized.id, original.id);
    expect(deserialized.name, original.name);
    expect(deserialized.thumbnail, original.thumbnail);
    expect(deserialized.category, original.category);
    expect(deserialized.isLocal, true);
    expect(deserialized.ingredients.length, 2);
    expect(deserialized.ingredients.last.name, 'Sambal');
  });
}
