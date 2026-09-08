// lib/patient/features/dashboard/controllers/patient_dashboard_controller.dart

import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/patient/features/dashboard/models/patient_summary.dart';
import 'package:doctor/patient/features/dashboard/repositories/patient_dashboard_repository.dart';
import 'package:doctor/patient/features/vitals/controllers/vitals_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PatientDashboardController extends GetxController {
  final PatientDashboardRepository _repository = PatientDashboardRepository();

  // State variables
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Data
  final summary = Rx<PatientSummary?>(null);
  final babySize = Rx<Map<String, dynamic>?>(null);

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
      final data = await _repository.getPatientSummary();

      if (data != null) {
        summary.value = data;

        // Fetch baby size reference if pregnancy data exists
        if (data.pregnancyProgress != null) {
          _fetchBabySize(data.pregnancyProgress!.currentWeek);
        }

        debugPrint('[PATIENT_DASHBOARD] Data loaded successfully');
      } else {
        // API returned null - show empty state
        summary.value = null;
        debugPrint('[PATIENT_DASHBOARD] No data returned from API');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load dashboard data. Please try again.';
      debugPrint('[PATIENT_DASHBOARD] Error loading data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchBabySize(int week) async {
    try {
      final data = await _repository.getBabySizeReference(week);
      if (data != null) {
        babySize.value = data;
      }
    } catch (e) {
      debugPrint('[PATIENT_DASHBOARD] Error fetching baby size: $e');
    }
  }

  Future<void> refreshData() async {
    await loadData();
  }

  void _checkForVitalsUpdate() {
    if (Get.isRegistered<VitalsController>()) {
      final vitalsController = Get.find<VitalsController>();
      if (vitalsController.justUpdatedVitals.value) {
        vitalsController.justUpdatedVitals.value = false;
        refreshData();
      }
    }
  }

  // Navigation methods
  void navigateToSymptoms() => Get.toNamed(AppRoutes.patientSymptoms);
  void navigateToWaterIntake() => Get.toNamed(AppRoutes.patientWaterIntake);
  void navigateToKickCount() => Get.toNamed(AppRoutes.patientKickCount);

  Future<void> navigateToVitals() async {
    await Get.toNamed(AppRoutes.patientVitals);
    _checkForVitalsUpdate();
  }

  void navigateToDietPlan() => Get.toNamed(AppRoutes.patientDietPlans);
  void navigateToAppointments() => Get.toNamed(AppRoutes.patientAppointments);
  void navigateToAppointmentDetail(int appointmentId) => Get.toNamed(
    AppRoutes.patientAppointmentDetail,
    arguments: {'appointmentId': appointmentId},
  );
  void navigateToMedicineReminders() =>
      Get.toNamed(AppRoutes.medicineReminders);
  void navigateToEmergency() => Get.toNamed(AppRoutes.patientEmergency);

  void navigateToSettings() => Get.toNamed(AppRoutes.patientSettings);

  void navigateToSurgicalProcedures() {
    Get.toNamed(AppRoutes.patientSurgicalProcedures);
  }

  void navigateToAIAssistant() {
    Get.toNamed(AppRoutes.patientAIAssistant);
  }

  void navigateToFindDoctors() {
    Get.toNamed(AppRoutes.findDoctors);
  }

  void navigateToExerciseVideos() {
    Get.toNamed(AppRoutes.patientExerciseVideos);
  }
}
