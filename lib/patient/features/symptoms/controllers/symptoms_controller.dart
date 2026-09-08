// lib/patient/features/symptoms/controllers/symptoms_controller.dart

import 'package:doctor/patient/features/symptoms/models/symptom_log.dart';
import 'package:doctor/patient/features/symptoms/repositories/symptoms_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SymptomsController extends GetxController {
  final SymptomsRepository _repository = Get.find<SymptomsRepository>();

  static const List<Map<String, dynamic>> _preSeededSymptoms = [
    {'id': 1, 'name': 'Nausea'},
    {'id': 2, 'name': 'Vomiting'},
    {'id': 3, 'name': 'Fatigue'},
    {'id': 4, 'name': 'Headache'},
    {'id': 5, 'name': 'Back pain'},
    {'id': 6, 'name': 'Swelling'},
    {'id': 7, 'name': 'Heartburn'},
    {'id': 8, 'name': 'Constipation'},
    {'id': 9, 'name': 'Dizziness'},
    {'id': 10, 'name': 'Shortness of breath'},
    {'id': 11, 'name': 'Leg cramps'},
    {'id': 12, 'name': 'Insomnia'},
    {'id': 13, 'name': 'Mood swings'},
    {'id': 14, 'name': 'Frequent urination'},
    {'id': 15, 'name': 'Braxton Hicks contractions'},
  ];

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
    symptomTypes.value = _preSeededSymptoms;
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