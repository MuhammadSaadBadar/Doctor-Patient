// lib/patient/features/symptoms/controllers/symptoms_controller.dart

import 'package:doctor/patient/features/symptoms/models/symptom_log.dart';
import 'package:doctor/patient/features/symptoms/repositories/symptoms_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SymptomsController extends GetxController {
  final SymptomsRepository _repository = SymptomsRepository();

  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final symptomLogs = <SymptomLog>[].obs;
  final symptomTypes = <Map<String, dynamic>>[].obs;
  final selectedSymptomIds = <int>[].obs;
  final notesController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadSymptoms();
    loadSymptomTypes();
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }

  Future<void> loadSymptoms() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final logs = await _repository.getSymptomLogs();
      symptomLogs.value = logs;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load symptoms. Please try again.';
      debugPrint('[SYMPTOMS] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSymptomTypes() async {
    try {
      final types = await _repository.getSymptomTypes();
      symptomTypes.value = types;
    } catch (e) {
      debugPrint('[SYMPTOMS] Error loading types: $e');
    }
  }

  Future<void> saveTodaysSymptoms() async {
    final today = DateTime.now();
    final logDate = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    if (selectedSymptomIds.isEmpty) {
      Get.snackbar('Error', 'Please select at least one symptom');
      return;
    }

    isLoading.value = true;
    try {
      final log = await _repository.createOrUpdateSymptomLog(
        logDate: logDate,
        symptomIds: selectedSymptomIds,
        notes: notesController.text.isEmpty ? null : notesController.text,
      );

      if (log != null) {
        Get.snackbar('Success', 'Symptoms saved successfully');
        notesController.clear();
        selectedSymptomIds.clear();
        await loadSymptoms();
      } else {
        Get.snackbar('Error', 'Failed to save symptoms');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong');
      debugPrint('[SYMPTOMS] Save error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleSymptom(int id) {
    if (selectedSymptomIds.contains(id)) {
      selectedSymptomIds.remove(id);
    } else {
      selectedSymptomIds.add(id);
    }
  }

  Future<void> refreshData() async {
    await loadSymptoms();
  }
}