// lib/patient/features/medicine_reminders/models/medicine_intake_log.dart

import 'package:flutter/material.dart';

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
      id: json['id'] ?? 0,
      reminderId: json['reminder'] ?? 0,
      scheduledFor:
          DateTime.tryParse(json['scheduled_for'] ?? '') ?? DateTime.now(),
      takenAt: json['taken_at'] != null
          ? DateTime.tryParse(json['taken_at'])
          : null,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  bool get isTaken => status == 'taken';
  bool get isSkipped => status == 'skipped';
  bool get isPending => status == 'pending';

  String get statusLabel {
    switch (status) {
      case 'taken':
        return 'Taken';
      case 'skipped':
        return 'Skipped';
      case 'pending':
        return 'Pending';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'taken':
        return Colors.green;
      case 'skipped':
        return Colors.orange;
      case 'pending':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'taken':
        return Icons.check_circle_rounded;
      case 'skipped':
        return Icons.history_toggle_off_rounded;
      case 'pending':
        return Icons.hourglass_top_rounded;
      default:
        return Icons.circle_rounded;
    }
  }
}
