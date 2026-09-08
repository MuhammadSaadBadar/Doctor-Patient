// lib/patient/features/diet_plans/models/diet_plan.dart

import 'dart:ui';

import 'package:doctor/patient/features/diet_plans/models/brief_user.dart';
import 'package:doctor/patient/features/diet_plans/models/diet_meal.dart';
import 'package:doctor/patient/features/diet_plans/models/food_avoidance.dart';
import 'package:flutter/material.dart';

class DietPlan {
  final int id;
  final int patientId;
  final BriefUser patient;
  final BriefUser createdBy;
  final bool isActive;
  final int? hydrationRecommendationMl;
  final int? hydrationRecommendationGlasses;
  final String? notes;
  final List<DietMeal> meals;
  final List<FoodAvoidance> foodsToAvoid;
  final DateTime createdAt;
  final DateTime updatedAt;

  DietPlan({
    required this.id,
    required this.patientId,
    required this.patient,
    required this.createdBy,
    required this.isActive,
    this.hydrationRecommendationMl,
    this.hydrationRecommendationGlasses,
    this.notes,
    required this.meals,
    required this.foodsToAvoid,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DietPlan.fromJson(Map<String, dynamic> json) {
    final mealsList = (json['meals'] as List<dynamic>? ?? [])
        .map((e) => DietMeal.fromJson(e as Map<String, dynamic>))
        .toList();

    final foodsList = (json['foods_to_avoid'] as List<dynamic>? ?? [])
        .map((e) => FoodAvoidance.fromJson(e as Map<String, dynamic>))
        .toList();

    return DietPlan(
      id: json['id'] ?? 0,
      patientId: json['patient']?['id'] ?? 0,
      patient: BriefUser.fromJson(json['patient'] ?? {}),
      createdBy: BriefUser.fromJson(json['created_by'] ?? {}),
      isActive: json['is_active'] ?? false,
      hydrationRecommendationMl: json['hydration_recommendation_ml'],
      hydrationRecommendationGlasses: json['hydration_recommendation_glasses'],
      notes: json['notes'],
      meals: mealsList,
      foodsToAvoid: foodsList,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  String get planNumber => '#$id';
  String get doctorFullName =>
      'Dr. ${createdBy.firstName} ${createdBy.lastName}';
  String get formattedCreatedAt {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[createdAt.month - 1]} ${createdAt.day}, ${createdAt.year}';
  }

  String get statusLabel => isActive ? 'Active' : 'Inactive';
  Color get statusColor => isActive ? Colors.green : Colors.grey;
  IconData get statusIcon =>
      isActive ? Icons.check_circle_rounded : Icons.lock_clock_rounded;

  int get mealCount => meals.length;
  int get foodsToAvoidCount => foodsToAvoid.length;
  bool get hasHydration => hydrationRecommendationGlasses != null;
  bool get hasMeals => meals.isNotEmpty;
  bool get hasFoodsToAvoid => foodsToAvoid.isNotEmpty;
  bool get hasNotes => notes != null && notes!.isNotEmpty;
}
