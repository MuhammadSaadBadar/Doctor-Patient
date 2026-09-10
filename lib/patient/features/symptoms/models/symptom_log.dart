import 'package:doctor/core/localization/translation_keys.dart';
import 'package:doctor/patient/features/dashboard/models/symptom.dart';
import 'package:get/get.dart';

class SymptomLog {
  final int id;
  final DateTime logDate;
  final List<Symptom> symptoms;
  final String? notes;

  SymptomLog({
    required this.id,
    required this.logDate,
    required this.symptoms,
    this.notes,
  });

  factory SymptomLog.fromJson(Map<String, dynamic> json) {
    final symptomsList = (json['symptoms'] as List<dynamic>? ?? [])
        .map((s) => Symptom.fromJson(s as Map<String, dynamic>))
        .toList();

    return SymptomLog(
      id: json['id'] ?? 0,
      logDate: DateTime.tryParse(json['log_date'] ?? '') ?? DateTime.now(),
      symptoms: symptomsList,
      notes: json['notes'],
    );
  }

  bool get isToday {
    final now = DateTime.now();
    return logDate.year == now.year &&
        logDate.month == now.month &&
        logDate.day == now.day;
  }

  String get dateLabel {
    if (isToday) return TranslationKeys.commonToday.tr;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    if (logDate.year == yesterday.year &&
        logDate.month == yesterday.month &&
        logDate.day == yesterday.day) {
      return TranslationKeys.commonYesterday.tr;
    }
    return '${logDate.day}/${logDate.month}/${logDate.year}';
  }
}
