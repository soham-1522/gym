class DietPlan {
  final String mealName;
  final String description;
  final int calories;
  final String mealType;
  final String imageUrl;

  DietPlan({
    required this.mealName,
    required this.description,
    required this.calories,
    required this.mealType,
    required this.imageUrl,
  });

  factory DietPlan.fromMap(Map<String, dynamic> data) {
    return DietPlan(
      mealName: data['mealName'] ?? '',
      description: data['description'] ?? '',
      calories: data['calories'] ?? 0,
      mealType: data['mealType'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'mealName': mealName,
      'description': description,
      'calories': calories,
      'mealType': mealType,
      'imageUrl': imageUrl,
    };
  }
}
