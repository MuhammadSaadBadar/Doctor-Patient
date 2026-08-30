// lib/patient/features/dashboard/models/blood_sugar_reading.dart

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
        return 'Fasting';
      case 'post_meal':
        return 'Post-Meal';
      default:
        return 'Random';
    }
  }

  bool get isNormal {
    if (readingContext == 'fasting') return valueMgDl < 100;
    if (readingContext == 'post_meal') return valueMgDl < 140;
    return valueMgDl < 140;
  }
}
