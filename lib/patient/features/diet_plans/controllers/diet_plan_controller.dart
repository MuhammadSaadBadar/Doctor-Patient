// lib/patient/features/diet_plans/controllers/diet_plan_controller.dart

import 'package:doctor/patient/features/diet_plans/models/diet_plan.dart';
import 'package:doctor/patient/features/diet_plans/repositories/diet_plan_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DietPlanController extends GetxController {
  final DietPlanRepository _repository = Get.find<DietPlanRepository>();

  // State
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Data
  final dietPlan = Rx<DietPlan?>(null);

  // Get diet plan ID from route arguments
  int? get planId => Get.arguments?['planId'] as int?;

  @override
  void onInit() {
    super.onInit();
    if (planId != null) {
      loadDietPlan();
    } else {
      hasError.value = true;
      errorMessage.value = 'Diet plan ID not found.';
      isLoading.value = false;
    }
  }

  Future<void> loadDietPlan() async {
    if (planId == null) return;

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await _repository.getDietPlanById(planId!);

      if (result != null) {
        dietPlan.value = result;
        debugPrint('[DIET_PLAN] Loaded plan: ${result.id}');
      } else {
        hasError.value = true;
        errorMessage.value = 'Diet plan not found. Please try again.';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Something went wrong. Please try again.';
      debugPrint('[DIET_PLAN] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadDietPlan();
  }

  // Navigation methods
  void navigateBack() {
    Get.back();
  }

  void navigateToDietPlans() {
    Get.toNamed('/diet-plans');
  }

  // Computed properties
  bool get hasData => dietPlan.value != null;
  bool get isActive => dietPlan.value?.isActive ?? false;

  String get planNumber => dietPlan.value?.planNumber ?? '#1';
  String get doctorName => dietPlan.value?.doctorFullName ?? 'Unknown';
  String get createdDate => dietPlan.value?.formattedCreatedAt ?? '';

  int get hydrationGlasses =>
      dietPlan.value?.hydrationRecommendationGlasses ?? 0;
  bool get hasHydration => dietPlan.value?.hasHydration ?? false;

  List<dynamic> get meals => dietPlan.value?.meals ?? [];
  List<dynamic> get foodsToAvoid => dietPlan.value?.foodsToAvoid ?? [];
  String? get notes => dietPlan.value?.notes;
}
