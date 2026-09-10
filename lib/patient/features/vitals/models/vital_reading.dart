// lib/patient/features/vitals/models/vital_reading.dart

import 'package:doctor/core/localization/translation_keys.dart';
import 'package:get/get.dart';

class BloodPressureReading {
  final int id;
  final int systolic;
  final int diastolic;
  final int? pulse;
  final DateTime recordedAt;
  final String? notes;

  BloodPressureReading({
    required this.id,
    required this.systolic,
    required this.diastolic,
    this.pulse,
    required this.recordedAt,
    this.notes,
  });

  factory BloodPressureReading.fromJson(Map<String, dynamic> json) {
    return BloodPressureReading(
      id: json['id'] ?? 0,
      systolic: json['systolic'] ?? 0,
      diastolic: json['diastolic'] ?? 0,
      pulse: json['pulse'],
      recordedAt:
          DateTime.tryParse(json['recorded_at'] ?? '') ?? DateTime.now(),
      notes: json['notes'],
    );
  }

  String get status {
    if (systolic < 120 && diastolic < 80) {
      return TranslationKeys.vitalsNormal.tr;
    }
    if (systolic < 130 && diastolic < 80) {
      return TranslationKeys.vitalsElevated.tr;
    }
    if (systolic < 140 || diastolic < 90) {
      return TranslationKeys.vitalsHighStageOne.tr;
    }
    return TranslationKeys.vitalsHighStageTwo.tr;
  }

  bool get isNormal => systolic < 120 && diastolic < 80;
}

class BloodSugarReading {
  final int id;
  final int valueMgDl;
  final String readingContext;
  final DateTime recordedAt;
  final String? notes;

  BloodSugarReading({
    required this.id,
    required this.valueMgDl,
    required this.readingContext,
    required this.recordedAt,
    this.notes,
  });

  factory BloodSugarReading.fromJson(Map<String, dynamic> json) {
    return BloodSugarReading(
      id: json['id'] ?? 0,
      valueMgDl: json['value_mg_dl'] ?? 0,
      readingContext: json['reading_context'] ?? 'random',
      recordedAt:
          DateTime.tryParse(json['recorded_at'] ?? '') ?? DateTime.now(),
      notes: json['notes'],
    );
  }

  String get contextLabel {
    switch (readingContext) {
      case 'fasting':
        return TranslationKeys.vitalsFasting.tr;
      case 'post_meal':
        return TranslationKeys.vitalsPostMeal.tr;
      default:
        return TranslationKeys.vitalsRandom.tr;
    }
  }

  bool get isNormal {
    if (readingContext == 'fasting') return valueMgDl < 100;
    if (readingContext == 'post_meal') return valueMgDl < 140;
    return valueMgDl < 140;
  }
}

class VitalReadingsResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<BloodPressureReading> bpResults;
  final List<BloodSugarReading> sugarResults;

  VitalReadingsResponse({
    required this.count,
    this.next,
    this.previous,
    required this.bpResults,
    required this.sugarResults,
  });
}
