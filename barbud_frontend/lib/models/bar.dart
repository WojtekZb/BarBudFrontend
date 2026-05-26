class UserBar {
  final int id;
  final String name;
  final int ingredientCount;

  UserBar({
    required this.id,
    required this.name,
    required this.ingredientCount,
  });

  factory UserBar.fromJson(Map<String, dynamic> json) {
    return UserBar(
      id: json["id"],
      name: json["name"],
      ingredientCount: json["amountIngredients"] ?? 0,
    );
  }
}