class BarIngredient {
  final int id;
  final String name;
  final String category;

  const BarIngredient({
    required this.id,
    required this.name,
    required this.category,
  });

  factory BarIngredient.fromJson(Map<String, dynamic> json) {
    return BarIngredient(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
    );
  }
}