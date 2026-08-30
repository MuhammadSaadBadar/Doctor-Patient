// lib/patient/features/water_intake/models/water_intake_entry.dart

class WaterIntakeEntry {
  final int id;
  final int amountMl;
  final DateTime loggedAt;
  final DateTime logDate;
  final DateTime createdAt;
  final PatientInfo? patient;

  WaterIntakeEntry({
    required this.id,
    required this.amountMl,
    required this.loggedAt,
    required this.logDate,
    required this.createdAt,
    this.patient,
  });

  factory WaterIntakeEntry.fromJson(Map<String, dynamic> json) {
    return WaterIntakeEntry(
      id: json['id'] ?? 0,
      amountMl: json['amount_ml'] ?? 0,
      loggedAt: DateTime.tryParse(json['logged_at'] ?? '') ?? DateTime.now(),
      logDate: DateTime.tryParse(json['log_date'] ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      patient: json['patient'] != null
          ? PatientInfo.fromJson(json['patient'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PatientInfo {
  final int id;
  final String email;
  final String firstName;
  final String lastName;

  PatientInfo({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  factory PatientInfo.fromJson(Map<String, dynamic> json) {
    return PatientInfo(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
    );
  }

  String get fullName => '$firstName $lastName';
}