// lib/features/patient/models/medicine_reminder.dart

import 'package:doctor/core/constants/color_constants.dart';
import 'package:flutter/material.dart';

/// Medicine reminder model for the doctor app
class MedicineReminder {
  final String id;
  final int patientId;
  final String patientName;
  final String medicineName;
  final String dosage;
  final int timesPerDay;
  final List<String> reminderTimes;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicineReminder({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.medicineName,
    required this.dosage,
    required this.timesPerDay,
    required this.reminderTimes,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicineReminder.fromJson(Map<String, dynamic> json) {
    final patient = json['patient'] as Map<String, dynamic>?;
    return MedicineReminder(
      id: json['id'].toString(),
      patientId: json['patient_id'] as int? ?? patient?['id'] as int? ?? 0,
      patientName:
          '${patient?['first_name'] ?? ''} ${patient?['last_name'] ?? ''}'
              .trim(),
      medicineName: json['medicine_name'] ?? '',
      dosage: json['dosage'] ?? '',
      timesPerDay: json['times_per_day'] as int? ?? 1,
      reminderTimes:
          (json['reminder_times'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'])
          : null,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicine_name': medicineName,
      'dosage': dosage,
      'times_per_day': timesPerDay,
      'reminder_times': reminderTimes,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'is_active': isActive,
    };
  }

  MedicineReminder copyWith({
    String? id,
    int? patientId,
    String? patientName,
    String? medicineName,
    String? dosage,
    int? timesPerDay,
    List<String>? reminderTimes,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicineReminder(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      medicineName: medicineName ?? this.medicineName,
      dosage: dosage ?? this.dosage,
      timesPerDay: timesPerDay ?? this.timesPerDay,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper to get status color
  Color get statusColor => isActive ? Colors.green : AppColors.onSurfaceVariant;

  // Helper to get status label
  String get statusLabel => isActive ? 'Active' : 'Inactive';

  // Format reminder times for display
  String get formattedTimes {
    return reminderTimes.map((t) => _formatTime(t)).join(' • ');
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
      }
      return time;
    } catch (_) {
      return time;
    }
  }

  // Get adherence summary (for display)
  String get adherenceSummary {
    return '$timesPerDay × daily';
  }

  // Check if reminder is due today
  bool get isDueToday {
    if (!isActive) return false;
    if (endDate != null && endDate!.isBefore(DateTime.now())) return false;
    return true;
  }
}

/// Medicine intake log model
class MedicineIntakeLog {
  final String id;
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
      id: json['id'].toString(),
      reminderId: json['reminder'] as int? ?? 0,
      scheduledFor:
          DateTime.tryParse(json['scheduled_for'] ?? '') ?? DateTime.now(),
      takenAt: json['taken_at'] != null
          ? DateTime.tryParse(json['taken_at'])
          : null,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Color get statusColor {
    switch (status) {
      case 'taken':
        return Colors.green;
      case 'skipped':
        return Colors.orange;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'taken':
        return 'Taken';
      case 'skipped':
        return 'Skipped';
      default:
        return 'Pending';
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'taken':
        return Icons.check_circle_rounded;
      case 'skipped':
        return Icons.block_rounded;
      default:
        return Icons.hourglass_empty_rounded;
    }
  }
}

/// Medicine reminder form model for creating/editing
class MedicineReminderForm {
  int? patientId;
  String medicineName;
  String dosage;
  int timesPerDay;
  List<String> reminderTimes;
  DateTime startDate;
  DateTime? endDate;
  bool isActive;

  MedicineReminderForm({
    this.patientId,
    this.medicineName = '',
    this.dosage = '',
    this.timesPerDay = 1,
    this.reminderTimes = const [],
    DateTime? startDate,
    this.endDate,
    this.isActive = true,
  }) : startDate = startDate ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      if (patientId != null) 'patient_id': patientId,
      'medicine_name': medicineName,
      'dosage': dosage,
      'times_per_day': timesPerDay,
      'reminder_times': reminderTimes,
      'start_date': startDate.toIso8601String().split('T')[0],
      if (endDate != null) 'end_date': endDate!.toIso8601String().split('T')[0],
      'is_active': isActive,
    };
  }

  factory MedicineReminderForm.fromReminder(MedicineReminder reminder) {
    return MedicineReminderForm(
      patientId: reminder.patientId,
      medicineName: reminder.medicineName,
      dosage: reminder.dosage,
      timesPerDay: reminder.timesPerDay,
      reminderTimes: List.from(reminder.reminderTimes),
      startDate: reminder.startDate,
      endDate: reminder.endDate,
      isActive: reminder.isActive,
    );
  }
}

/// Result class for paginated medicine reminders
class MedicineReminderListResult {
  final List<MedicineReminder> reminders;
  final int totalCount;
  final bool hasNext;

  MedicineReminderListResult({
    required this.reminders,
    required this.totalCount,
    required this.hasNext,
  });
}
