// lib/patient/features/dashboard/models/pregnancy_progress.dart

import 'package:doctor/core/localization/translation_keys.dart';
import 'package:get/get.dart';

class PregnancyProgress {
  final String lmpDate;
  final String eddDate;
  final int currentWeek;
  final int currentDay;
  final double percentComplete;
  final int trimester;
  final int daysRemaining;

  PregnancyProgress({
    required this.lmpDate,
    required this.eddDate,
    required this.currentWeek,
    required this.currentDay,
    required this.percentComplete,
    required this.trimester,
    required this.daysRemaining,
  });

  factory PregnancyProgress.fromJson(Map<String, dynamic> json) {
    return PregnancyProgress(
      lmpDate: json['lmp_date'] ?? '',
      eddDate: json['edd_date'] ?? '',
      currentWeek: json['current_week'] ?? 0,
      currentDay: json['current_day'] ?? 0,
      percentComplete: (json['percent_complete'] ?? 0.0).toDouble(),
      trimester: json['trimester'] ?? 1,
      daysRemaining: json['days_remaining'] ?? 0,
    );
  }

  String get trimesterLabel {
    switch (trimester) {
      case 1:
        return TranslationKeys.dashboardFirstTrimester.tr;
      case 2:
        return TranslationKeys.dashboardSecondTrimester.tr;
      case 3:
        return TranslationKeys.dashboardThirdTrimester.tr;
      default:
        return '';
    }
  }
}
