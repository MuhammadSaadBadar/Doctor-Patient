import 'dart:ui';

import 'package:doctor/core/constants/color_constants.dart';

enum DietPlanStatus { active, inactive }

class DietPlan {
  final String id;
  final String title;
  final String description;
  final DietPlanStatus status;
  final DateTime createdAt;
  final int? patientId;
  final String? patientName;
  final String? createdBy;
  final int? hydrationRecommendationMl;
  final String? notes;
  final List<DietPlanMeal> meals;
  final List<DietPlanFoodAvoidance> foodsToAvoid;

  int? _planNumber;

  DietPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.patientId,
    this.patientName,
    this.createdBy,
    this.hydrationRecommendationMl,
    this.notes,
    this.meals = const [],
    this.foodsToAvoid = const [],
  });

  int get planNumber => _planNumber ?? 0;

  void setPlanNumber(int n) => _planNumber = n;

  String get statusDisplay {
    switch (status) {
      case DietPlanStatus.active:
        return 'ACTIVE';
      case DietPlanStatus.inactive:
        return 'INACTIVE';
    }
  }

  Color get statusBgColor {
    switch (status) {
      case DietPlanStatus.active:
        return AppColors.secondaryFixed.withValues(alpha: 0.3);
      case DietPlanStatus.inactive:
        return AppColors.surfaceVariant;
    }
  }

  Color get statusTextColor {
    switch (status) {
      case DietPlanStatus.active:
        return AppColors.secondaryFixedDim;
      case DietPlanStatus.inactive:
        return AppColors.onSurfaceVariant;
    }
  }

  bool get hasBorder {
    return status == DietPlanStatus.active;
  }

  double get opacity {
    return status == DietPlanStatus.inactive ? 0.8 : 1.0;
  }

  factory DietPlan.fromJson(Map<String, dynamic> json) {
    final patient = json['patient'] as Map<String, dynamic>?;
    final createdBy = json['created_by'] as Map<String, dynamic>?;

    return DietPlan(
      id: json['id'].toString(),
      title: json['title'] ?? json['name'] ?? 'Untitled Plan',
      description: json['notes'] ?? json['description'] ?? '',
      status: json['is_active'] == true
          ? DietPlanStatus.active
          : DietPlanStatus.inactive,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      patientId: json['patient_id'] as int? ?? patient?['id'] as int?,
      patientName: patient != null
          ? '${patient['first_name'] ?? ''} ${patient['last_name'] ?? ''}'
                .trim()
          : null,
      createdBy: createdBy != null
          ? '${createdBy['first_name'] ?? ''} ${createdBy['last_name'] ?? ''}'
                .trim()
          : null,
      hydrationRecommendationMl: json['hydration_recommendation_ml'] as int?,
      notes: json['notes'] as String?,
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
  final int? id;
  final String mealType;
  final String description;

  DietPlanMeal({this.id, required this.mealType, required this.description});

  factory DietPlanMeal.fromJson(Map<String, dynamic> json) {
    return DietPlanMeal(
      id: json['id'] as int?,
      mealType: json['meal_type'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class DietPlanFoodAvoidance {
  final int? id;
  final String foodName;
  final String reason;

  DietPlanFoodAvoidance({
    this.id,
    required this.foodName,
    required this.reason,
  });

  factory DietPlanFoodAvoidance.fromJson(Map<String, dynamic> json) {
    return DietPlanFoodAvoidance(
      id: json['id'] as int?,
      foodName: json['food_name'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }
}