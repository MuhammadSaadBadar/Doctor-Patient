class DietPlanFormData {
  String id;
  String description;
  int? hydrationRecommendationMl;
  int? patientId;
  List<DietPlanMeal> meals;
  List<DietPlanFoodAvoidance> foodsToAvoid;

  DietPlanFormData({
    this.id = '',
    this.description = '',
    this.hydrationRecommendationMl,
    this.patientId,
    this.meals = const [],
    this.foodsToAvoid = const [],
  });

  DietPlanFormData copyWith({
    String? id,
    String? description,
    int? hydrationRecommendationMl,
    int? patientId,
    List<DietPlanMeal>? meals,
    List<DietPlanFoodAvoidance>? foodsToAvoid,
  }) {
    return DietPlanFormData(
      id: id ?? this.id,
      description: description ?? this.description,
      hydrationRecommendationMl: hydrationRecommendationMl ?? this.hydrationRecommendationMl,
      patientId: patientId ?? this.patientId,
      meals: meals ?? this.meals,
      foodsToAvoid: foodsToAvoid ?? this.foodsToAvoid,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      if (patientId != null) 'patient_id': patientId,
      'hydration_recommendation_ml': hydrationRecommendationMl,
      'notes': description,
      'meals': meals.map((m) => m.toJson()).toList(),
      'foods_to_avoid': foodsToAvoid.map((f) => f.toJson()).toList(),
    };
    // Ensure patient_id is always present for updates when we have it
    if (id.isNotEmpty && patientId != null) {
      json['patient_id'] = patientId;
    }
    return json;
  }

  factory DietPlanFormData.fromJson(Map<String, dynamic> json) {
    final patient = json['patient'] as Map<String, dynamic>?;
    return DietPlanFormData(
      id: json['id']?.toString() ?? '',
      description: json['notes'] ?? json['description'] ?? '',
      hydrationRecommendationMl: json['hydration_recommendation_ml'] as int?,
      patientId: json['patient_id'] as int? ?? patient?['id'] as int?,
      meals:
          (json['meals'] as List?)
              ?.map((e) => DietPlanMeal.fromJson(e))
              .toList() ??
          [],
      foodsToAvoid:
          (json['foods_to_avoid'] as List?)
              ?.map((e) => DietPlanFoodAvoidance.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class DietPlanMeal {
  final String mealType;
  final String description;

  DietPlanMeal({required this.mealType, required this.description});

  Map<String, dynamic> toJson() {
    return {'meal_type': mealType, 'description': description};
  }

  factory DietPlanMeal.fromJson(Map<String, dynamic> json) {
    return DietPlanMeal(
      mealType: json['meal_type'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class DietPlanFoodAvoidance {
  final String foodName;
  final String reason;

  DietPlanFoodAvoidance({required this.foodName, required this.reason});

  Map<String, dynamic> toJson() {
    return {'food_name': foodName, 'reason': reason};
  }

  factory DietPlanFoodAvoidance.fromJson(Map<String, dynamic> json) {
    return DietPlanFoodAvoidance(
      foodName: json['food_name'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }
}