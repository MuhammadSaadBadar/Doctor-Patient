// lib/patient/features/diet_plans/models/food_avoidance.dart

class FoodAvoidance {
  final int id;
  final String foodName;
  final String? reason;

  FoodAvoidance({required this.id, required this.foodName, this.reason});

  factory FoodAvoidance.fromJson(Map<String, dynamic> json) {
    return FoodAvoidance(
      id: json['id'] ?? 0,
      foodName: json['food_name'] ?? '',
      reason: json['reason'],
    );
  }
}
