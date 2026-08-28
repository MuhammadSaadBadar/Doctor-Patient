import 'package:get/get.dart';
import 'package:doctor/features/patient/repositories/patient_repository.dart';
import 'package:doctor/features/patient/models/patient_card.dart';
import 'package:flutter/material.dart';

class PatientManagementController extends GetxController {
  final PatientRepository _patientRepository = PatientRepository();

  final allPatients = <PatientCard>[].obs;
  final filteredPatients = <PatientCard>[].obs;
  final searchQuery = ''.obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPatients();

    // Re-filter patients whenever the search query changes
    ever(searchQuery, (_) => _filterPatients());
  }

  Future<void> _loadPatients() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final patients = await _patientRepository.getAssignedPatients();
      allPatients.value = patients;
      _filterPatients();

      debugPrint('[PATIENT_MANAGEMENT] Loaded ${patients.length} patients');
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load patients. Please try again.';
      debugPrint('[PATIENT_MANAGEMENT] Error loading patients: $e');
      // Clear patients on error
      allPatients.clear();
      filteredPatients.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void _filterPatients() {
    if (searchQuery.value.isEmpty) {
      filteredPatients.value = allPatients.value;
      return;
    }

    final query = searchQuery.value.toLowerCase();
    filteredPatients.value = allPatients
        .where(
          (patient) =>
              patient.fullName.toLowerCase().contains(query) ||
              patient.patientId.toLowerCase().contains(query) ||
              patient.email.toLowerCase().contains(query),
        )
        .toList();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  Future<void> refreshPatients() async {
    await _loadPatients();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
