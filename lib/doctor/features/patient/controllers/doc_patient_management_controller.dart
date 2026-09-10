import 'package:get/get.dart';
import 'package:doctor/doctor/features/patient/repositories/doc_patient_repository.dart';
import 'package:doctor/doctor/features/patient/models/doc_patient_card.dart';
import 'package:flutter/material.dart';

class DoctorPatientManagementController extends GetxController {
  final DoctorPatientRepository _patientRepository = DoctorPatientRepository();

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
      filteredPatients.assignAll(allPatients);
      return;
    }

    final query = searchQuery.value.toLowerCase();
    filteredPatients.assignAll(
      allPatients.where(
        (patient) =>
            patient.fullName.toLowerCase().contains(query) ||
            patient.patientId.toLowerCase().contains(query) ||
            patient.email.toLowerCase().contains(query),
      ).toList(),
    );
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
