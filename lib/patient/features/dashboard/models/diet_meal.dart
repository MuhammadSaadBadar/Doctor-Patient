// lib/patient/features/dashboard/models/diet_meal.dart

class DietMeal {
  final int id;
  final String mealType;
  final String description;

  DietMeal({
    required this.id,
    required this.mealType,
    required this.description,
  });

  factory DietMeal.fromJson(Map<String, dynamic> json) {
    return DietMeal(
      id: json['id'] ?? 0,
      mealType: json['meal_type'] ?? '',
      description: json['description'] ?? '',
    );
  }

  String get mealTypeLabel {
    switch (mealType) {
      case 'breakfast':
        return '🍳 Breakfast';
      case 'lunch':
        return '🥗 Lunch';
      case 'dinner':
        return '🍽️ Dinner';
      case 'snack':
        return '🍿 Snack';
      default:
        return mealType;
    }
  }
}
