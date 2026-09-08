import 'package:doctor/patient/features/diet_plans/models/diet_plan.dart';
import 'package:doctor/patient/features/diet_plans/repositories/diet_plan_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DietPlanListController extends GetxController {
  final DietPlanRepository _repository = Get.find<DietPlanRepository>();

  final plans = <DietPlan>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final hasMore = true.obs;
  final currentPage = 1.obs;

  @override
  void onInit() {
    super.onInit();
    loadPlans();
  }

  Future<void> loadPlans({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMore.value = true;
      plans.clear();
    }
    if (!hasMore.value) return;

    isLoading.value = plans.isEmpty;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await _repository.getDietPlans(
        page: currentPage.value,
        pageSize: 20,
      );
      if (result == null) {
        hasError.value = true;
        errorMessage.value = 'Failed to load diet plans. Please try again.';
        return;
      }
      plans.addAll(result.results);
      hasMore.value = result.hasNext;
      currentPage.value++;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Something went wrong. Please try again.';
      debugPrint('[DIET_PLAN_LIST] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() => loadPlans(refresh: true);

  Future<void> loadMore() async {
    if (!isLoading.value && hasMore.value) await loadPlans();
  }

  void openPlan(DietPlan plan) {
    Get.toNamed('/patient/diet-plan', arguments: {'planId': plan.id});
  }
}
