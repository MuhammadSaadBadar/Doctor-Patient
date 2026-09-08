// lib/patient/features/water_intake/controllers/water_intake_controller.dart

import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/patient/features/water_intake/models/today_water_intake.dart';
import 'package:doctor/patient/features/water_intake/models/weekly_water_intake.dart';
import 'package:doctor/patient/features/water_intake/repositories/water_intake_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WaterIntakeController extends GetxController {
  final WaterIntakeRepository _repository = WaterIntakeRepository();

  // State
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final isLogging = false.obs;

  // Data
  final todayIntake = Rx<TodayWaterIntake?>(null);
  final weeklyIntake = Rx<WeeklyWaterIntake?>(null);

  // Constants
  final targetMl = 2500.obs; // 2.5L daily goal

  // Computed getters
  int get totalMl => todayIntake.value?.totalMl ?? 0;
  int get glasses => todayIntake.value?.glasses ?? 0;
  double get progress => (totalMl / targetMl.value).clamp(0.0, 1.0);
  int get remainingMl =>
      (targetMl.value - totalMl).clamp(0, targetMl.value.toInt());

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
      final today = await _repository.getTodayIntake();
      todayIntake.value = today;

      final weekly = await _repository.getWeeklyIntake();
      weeklyIntake.value = weekly;

      debugPrint('[WATER_INTAKE] Data loaded successfully');
    } catch (e) {
      hasError.value = true;
      errorMessage.value =
          'Failed to load water intake data. Please try again.';
      debugPrint('[WATER_INTAKE] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadData();
  }

  Future<void> addWater(int amountMl) async {
    if (isLogging.value) return;

    isLogging.value = true;
    try {
      final entry = await _repository.logWaterIntake(amountMl: amountMl);

      if (entry != null) {
        // Refresh data to update UI
        await loadData();
        Get.snackbar(
          'Success',
          'Added ${amountMl}ml water 💧',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to log water intake. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('[WATER_INTAKE] Error adding water: $e');
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLogging.value = false;
    }
  }

  // Navigation methods
  void navigateToHistory() => Get.toNamed(AppRoutes.patientWaterIntakeHistory);

  void navigateToHome() => Get.offAllNamed(AppRoutes.patientDashboard);

  void navigateToBooking() => Get.toNamed(AppRoutes.patientAppointmentDetail);

  void navigateToReports() => Get.toNamed('/patient/reports');

  void navigateToProfile() => Get.toNamed(AppRoutes.patientEditProfile);
}
