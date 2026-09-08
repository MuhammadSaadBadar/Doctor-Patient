// lib/patient/features/vitals/controllers/vitals_controller.dart

import 'package:doctor/patient/features/vitals/models/vital_reading.dart';
import 'package:doctor/patient/features/vitals/repositories/vitals_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VitalsController extends GetxController {
  final VitalsRepository _repository = VitalsRepository();

  // State variables
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final bpHistory = <BloodPressureReading>[].obs;
  final sugarHistory = <BloodSugarReading>[].obs;
  final selectedTab = 0.obs; // 0 = BP, 1 = Sugar

  // ✅ ADDED: Flag to indicate vitals were updated
  final justUpdatedVitals = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final bp = await _repository.getBloodPressureHistory();
      final sugar = await _repository.getBloodSugarHistory();
      bpHistory.value = bp;
      sugarHistory.value = sugar;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load vitals data.';
      debugPrint('[VITALS] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logBloodPressure({
    required int systolic,
    required int diastolic,
    int? pulse,
    String? notes,
  }) async {
    final reading = await _repository.logBloodPressure(
      systolic: systolic,
      diastolic: diastolic,
      pulse: pulse,
      notes: notes,
    );
    if (reading != null) {
      bpHistory.insert(0, reading);
      justUpdatedVitals.value = true; // ✅ Set flag when vitals are logged
      Get.snackbar(
        'Logged',
        'Blood pressure recorded',
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar('Error', 'Failed to log blood pressure');
    }
  }

  Future<void> logBloodSugar({
    required int valueMgDl,
    required String readingContext,
    String? notes,
  }) async {
    final reading = await _repository.logBloodSugar(
      valueMgDl: valueMgDl,
      readingContext: readingContext,
      notes: notes,
    );
    if (reading != null) {
      sugarHistory.insert(0, reading);
      justUpdatedVitals.value = true; // ✅ Set flag when vitals are logged
      Get.snackbar(
        'Logged',
        'Blood sugar recorded',
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar('Error', 'Failed to log blood sugar');
    }
  }

  // ✅ FIXED: Proper refresh method with flag management
  Future<void> refreshData() async {
    await loadData();
    // Reset flag after refresh
    justUpdatedVitals.value = false;
  }

  // ✅ ADDED: Method to explicitly reset the flag
  void resetVitalsUpdateFlag() {
    justUpdatedVitals.value = false;
  }
}
