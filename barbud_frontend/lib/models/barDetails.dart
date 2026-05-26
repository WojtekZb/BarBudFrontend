import 'package:barbud_frontend/models/ingredient.dart';

class BarDetails {
  final int id;
  final String name;
  final int ingredientCount;
  final List<BarIngredient> ingredients;

  BarDetails({
    required this.id,
    required this.name,
    required this.ingredientCount,
    required this.ingredients,
  });

  factory BarDetails.fromJson(Map<String, dynamic> json) {
    final ingredientsJson = json["ingredients"] as List<dynamic>? ?? [];

    return BarDetails(
      id: json["id"],
      name: json["name"],
      ingredientCount: json["amountIngredients"] ?? ingredientsJson.length,
      ingredients: ingredientsJson
          .map((ingredient) => BarIngredient.fromJson(ingredient))
          .toList(),
    );
  }
}