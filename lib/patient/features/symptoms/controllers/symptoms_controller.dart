// lib/patient/features/symptoms/controllers/symptoms_controller.dart

import 'package:doctor/core/localization/translation_keys.dart';
import 'package:doctor/patient/features/symptoms/models/symptom_log.dart';
import 'package:doctor/patient/features/symptoms/repositories/symptoms_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SymptomsController extends GetxController {
  final SymptomsRepository _repository = Get.find<SymptomsRepository>();

static const List<Map<String, dynamic>> _preSeededSymptoms = [
 {'id': 1, 'key': 'symptom.nausea'},
 {'id': 2, 'key': 'symptom.vomiting'},
 {'id': 3, 'key': 'symptom.fatigue'},
 {'id': 4, 'key': 'symptom.headache'},
 {'id': 5, 'key': 'symptom.backPain'},
 {'id': 6, 'key': 'symptom.swelling'},
 {'id': 7, 'key': 'symptom.heartburn'},
 {'id': 8, 'key': 'symptom.constipation'},
 {'id': 9, 'key': 'symptom.dizziness'},
 {'id': 10, 'key': 'symptom.shortnessOfBreath'},
 {'id': 11, 'key': 'symptom.legCramps'},
 {'id': 12, 'key': 'symptom.insomnia'},
 {'id': 13, 'key': 'symptom.moodSwings'},
 {'id': 14, 'key': 'symptom.frequentUrination'},
 {'id': 15, 'key': 'symptom.braxtonHicksContractions'},
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
      errorMessage.value = TranslationKeys.symptomsLoadFailed.tr;
      debugPrint('[SYMPTOMS] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSymptomTypes() async {
    symptomTypes.value = _preSeededSymptoms.map((symptom) {
      final id = symptom['id'] as int;
      String translatedName;
      switch (id) {
        case 1:
          translatedName = TranslationKeys.symptomNausea.tr;
          break;
        case 2:
          translatedName = TranslationKeys.symptomVomiting.tr;
          break;
        case 3:
          translatedName = TranslationKeys.symptomFatigue.tr;
          break;
        case 4:
          translatedName = TranslationKeys.symptomHeadache.tr;
          break;
        case 5:
          translatedName = TranslationKeys.symptomBackPain.tr;
          break;
        case 6:
          translatedName = TranslationKeys.symptomSwelling.tr;
          break;
        case 7:
          translatedName = TranslationKeys.symptomHeartburn.tr;
          break;
        case 8:
          translatedName = TranslationKeys.symptomConstipation.tr;
          break;
        case 9:
          translatedName = TranslationKeys.symptomDizziness.tr;
          break;
        case 10:
          translatedName = TranslationKeys.symptomShortnessOfBreath.tr;
          break;
        case 11:
          translatedName = TranslationKeys.symptomLegCramps.tr;
          break;
        case 12:
          translatedName = TranslationKeys.symptomInsomnia.tr;
          break;
        case 13:
          translatedName = TranslationKeys.symptomMoodSwings.tr;
          break;
        case 14:
          translatedName = TranslationKeys.symptomFrequentUrination.tr;
          break;
        case 15:
          translatedName = TranslationKeys.symptomBraxtonHicksContractions.tr;
          break;
        default:
          translatedName = TranslationKeys.symptomNausea.tr;
      }
      return {'id': id, 'name': translatedName};
    }).toList();
  }

  Future<void> saveTodaysSymptoms() async {
    final today = DateTime.now();
    final logDate = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    if (selectedSymptomIds.isEmpty) {
      Get.snackbar(TranslationKeys.commonError.tr, TranslationKeys.symptomsSelectAtLeastOne.tr);
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
        Get.snackbar(TranslationKeys.commonSuccess.tr, TranslationKeys.symptomsSaveSuccess.tr);
        notesController.clear();
        selectedSymptomIds.clear();
        await loadSymptoms();
      } else {
        Get.snackbar(TranslationKeys.commonError.tr, TranslationKeys.symptomsSaveFailed.tr);
      }
    } catch (e) {
      Get.snackbar(TranslationKeys.commonError.tr, TranslationKeys.commonSomethingWentWrong.tr);
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