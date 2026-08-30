// lib/patient/features/dashboard/models/blood_pressure_reading.dart

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
    if (systolic < 120 && diastolic < 80) return 'Normal';
    if (systolic < 130 && diastolic < 80) return 'Elevated';
    if (systolic < 140 || diastolic < 90) return 'High Stage 1';
    return 'High Stage 2';
  }

  bool get isNormal => systolic < 120 && diastolic < 80;
}
