// lib/patient/features/dashboard/models/diet_plan_summary.dart

import 'package:doctor/patient/features/dashboard/models/diet_meal.dart';

class DietPlanSummary {
  final int id;
  final String doctorFirstName;
  final String doctorLastName;
  final int hydrationMl;
  final int hydrationGlasses;
  final List<DietMeal> meals;
  final List<String> foodsToAvoid;
  final String? notes;

  DietPlanSummary({
    required this.id,
    required this.doctorFirstName,
    required this.doctorLastName,
    required this.hydrationMl,
    required this.hydrationGlasses,
    required this.meals,
    required this.foodsToAvoid,
    this.notes,
  });

  factory DietPlanSummary.fromJson(Map<String, dynamic> json) {
    final createdBy = json['created_by'] as Map<String, dynamic>? ?? {};
    final mealsList = (json['meals'] as List<dynamic>? ?? [])
        .map((m) => DietMeal.fromJson(m as Map<String, dynamic>))
        .toList();
    final foodsToAvoidList = (json['foods_to_avoid'] as List<dynamic>? ?? [])
        .map((f) => f.toString())
        .toList();

    return DietPlanSummary(
      id: json['id'] ?? 0,
      doctorFirstName: createdBy['first_name'] ?? '',
      doctorLastName: createdBy['last_name'] ?? '',
      hydrationMl: json['hydration_recommendation_ml'] ?? 0,
      hydrationGlasses: json['hydration_recommendation_glasses'] ?? 0,
      meals: mealsList,
      foodsToAvoid: foodsToAvoidList,
      notes: json['notes'],
    );
  }

  String get doctorFullName => 'Dr. $doctorFirstName $doctorLastName';
  bool get hasMeals => meals.isNotEmpty;
  bool get hasFoodsToAvoid => foodsToAvoid.isNotEmpty;
}
