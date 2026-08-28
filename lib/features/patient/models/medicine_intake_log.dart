// lib/features/patient/models/medicine_intake_log.dart
class MedicineIntakeLog {
  final int id;
  final int reminderId;
  final DateTime scheduledFor;
  final DateTime? takenAt;
  final String status; // 'pending', 'taken', 'skipped'
  final DateTime createdAt;

  MedicineIntakeLog({
    required this.id,
    required this.reminderId,
    required this.scheduledFor,
    this.takenAt,
    required this.status,
    required this.createdAt,
  });

  factory MedicineIntakeLog.fromJson(Map<String, dynamic> json) {
    return MedicineIntakeLog(
      id: json['id'],
      reminderId: json['reminder'],
      scheduledFor: DateTime.parse(json['scheduled_for']),
      takenAt: json['taken_at'] != null
          ? DateTime.parse(json['taken_at'])
          : null,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
