import 'package:get/get.dart';
import 'package:doctor/doctor/features/patient/repositories/doc_patient_repository.dart';
import 'package:doctor/doctor/features/patient/models/doc_diet_plan.dart';
import 'package:flutter/material.dart';

class DoctorDietPlansController extends GetxController {
  final DoctorPatientRepository _repository = DoctorPatientRepository();

  final plans = <DietPlan>[].obs;
  final filteredPlans = <DietPlan>[].obs;
  final selectedFilter = Rx<DietPlanStatus?>(null);
  final sortByDate = true.obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Pagination
  final currentPage = 1.obs;
  final hasMoreData = true.obs;
  final isLastPage = false.obs;
  final totalCount = 0.obs;

  // Patient ID for filtering
  int? patientId;

  @override
  void onInit() {
    super.onInit();

    // Get patient ID from arguments
    final args = Get.arguments;
    if (args is Map) {
      patientId = args['patientId'] as int?;
    }

    _loadAllPlansForNumbering();

    // Listen to changes in filter or sort
    ever(selectedFilter, (_) => _applyFilters());
    ever(sortByDate, (_) => _applyFilters());
  }

  /// Load ALL plans once to assign stable plan numbers based on ID order
  Future<void> _loadAllPlansForNumbering() async {
    if (patientId == null) return;

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final allPlans = await _repository.getAllDietPlans(patientId!);

      // Store the full list with stable numbering
      plans.value = allPlans;
      totalCount.value = allPlans.length;

      // For pagination display, we'll use the first page initially
      _applyFilters();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load diet plans. Please try again.';
      debugPrint('[DIET_PLANS] Error loading plans: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load paginated plans for display (after initial full load)
  Future<void> _loadPaginatedPlans({bool loadMore = false}) async {
    if (patientId == null) return;
    if (loadMore && !hasMoreData.value) return;

    if (loadMore) {
      currentPage.value++;
    } else {
      currentPage.value = 1;
      hasMoreData.value = true;
      isLastPage.value = false;
    }

    try {
      final result = await _repository.getDietPlansPaginated(
        patientId: patientId,
        page: currentPage.value,
        pageSize: 20,
      );

      // We don't replace plans.value here since it already has all plans with stable numbering
      // We just update pagination state
      isLastPage.value = !result.hasNext;
      hasMoreData.value = result.hasNext;
    } catch (e) {
      debugPrint('[DIET_PLANS] Error loading paginated plans: $e');
    }
  }

  void _applyFilters() {
    var filtered = List<DietPlan>.from(plans.value);

    // Apply status filter
    if (selectedFilter.value != null) {
      filtered = filtered
          .where((p) => p.status == selectedFilter.value)
          .toList();
    }

    // Apply sorting (for display order only - planNumber stays stable)
    if (sortByDate.value) {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      filtered.sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
    }

    filteredPlans.value = filtered;
  }

  void setFilter(DietPlanStatus? status) {
    selectedFilter.value = status;
  }

  void toggleSort() {
    sortByDate.value = !sortByDate.value;
  }

  Future<void> loadMore() async {
    if (!isLoading.value && hasMoreData.value) {
      await _loadPaginatedPlans(loadMore: true);
    }
  }

  Future<void> refreshPlans() async {
    await _loadAllPlansForNumbering();
  }

  void applyFilters() {
    _applyFilters();
  }

  /// Delete a diet plan and refresh
  Future<bool> deletePlan(String planId) async {
    final success = await _repository.deleteDietPlan(planId);
    if (success) {
      // Remove from local list and renumber
      plans.removeWhere((p) => p.id == planId);
      // Renumber remaining plans
      final sortedPlans = List<DietPlan>.from(plans.value)
        ..sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
      for (int i = 0; i < sortedPlans.length; i++) {
        sortedPlans[i].setPlanNumber(i + 1);
      }
      plans.value = sortedPlans;
      _applyFilters();
    }
    return success;
  }

  @override
  void onClose() {
    super.onClose();
  }
}
