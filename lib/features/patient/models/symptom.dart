import 'dart:ui';

import 'package:doctor/core/constants/color_constants.dart';

enum SymptomSeverity { mild, moderate, severe }

class Symptom {
  final String id;
  final String name;
  final String date;
  final String time;
  final SymptomSeverity severity;
  final String? notes;

  Symptom({
    required this.id,
    required this.name,
    required this.date,
    required this.time,
    required this.severity,
    this.notes,
  });

  String get severityDisplay {
    switch (severity) {
      case SymptomSeverity.mild:
        return 'Mild';
      case SymptomSeverity.moderate:
        return 'Moderate';
      case SymptomSeverity.severe:
        return 'Severe';
    }
  }

  Color get severityColor {
    switch (severity) {
      case SymptomSeverity.mild:
        return AppColors.surfaceVariant;
      case SymptomSeverity.moderate:
        return AppColors.secondaryFixed;
      case SymptomSeverity.severe:
        return AppColors.errorContainer;
    }
  }

  Color get severityTextColor {
    switch (severity) {
      case SymptomSeverity.mild:
        return AppColors.onSurface;
      case SymptomSeverity.moderate:
        return AppColors.onSecondaryFixed;
      case SymptomSeverity.severe:
        return AppColors.onErrorContainer;
    }
  }


  factory Symptom.fromLog(Map<String, dynamic> log) {
    // Parse symptoms from the log
    final symptoms = log['symptoms'] as List<dynamic>? ?? [];
    final symptomNames = symptoms.map((s) => s['name'] as String).toList();

    return Symptom(
      id: log['id'].toString(),
      name: symptomNames.isNotEmpty
          ? symptomNames.join(', ')
          : 'No symptoms logged',
      date: log['log_date']?.toString() ?? 'Unknown',
      time: 'N/A', // API doesn't provide time
      severity: _parseSeverity(log['severity']),
      notes: log['notes'] as String?,
    );
  }

  static SymptomSeverity _parseSeverity(dynamic severity) {
    if (severity == null) return SymptomSeverity.mild;
    final str = severity.toString().toLowerCase();
    if (str.contains('severe')) return SymptomSeverity.severe;
    if (str.contains('moderate')) return SymptomSeverity.moderate;
    return SymptomSeverity.mild;
  }
}
