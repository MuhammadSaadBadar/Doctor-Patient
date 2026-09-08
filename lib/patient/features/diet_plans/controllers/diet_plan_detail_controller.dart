// lib/patient/features/diet_plan/controllers/diet_plan_detail_controller.dart

import 'package:doctor/patient/features/dashboard/models/diet_plan_summary.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DietPlanDetailController extends GetxController {
  final int planId;
  final DietPlanSummary? initialPlan;

  DietPlanDetailController({required this.planId, this.initialPlan});

  final isLoading = false.obs;
  final plan = Rx<DietPlanSummary?>(null);

  @override
  void onInit() {
    super.onInit();
    if (initialPlan != null) {
      plan.value = initialPlan;
    }
  }

  String get doctorName => plan.value?.doctorFullName ?? 'Unknown Doctor';
  int get hydrationGlasses => plan.value?.hydrationGlasses ?? 0;
  int get hydrationMl => plan.value?.hydrationMl ?? 0;
  List get meals => plan.value?.meals ?? [];
  String get notes => plan.value?.notes ?? '';
}