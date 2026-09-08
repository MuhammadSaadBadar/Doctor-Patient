// lib/patient/features/medicine_reminders/models/medicine_reminder.dart

import 'package:doctor/patient/features/medicine_reminders/models/medicine_adherence.dart';
import 'package:flutter/material.dart';

class MedicineReminder {
  final int id;
  final int patientId;
  final String medicineName;
  final String dosage;
  final int timesPerDay;
  final List<String> reminderTimes;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MedicineAdherence? adherence;

  MedicineReminder({
    required this.id,
    required this.patientId,
    required this.medicineName,
    required this.dosage,
    required this.timesPerDay,
    required this.reminderTimes,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.adherence,
  });

  factory MedicineReminder.fromJson(Map<String, dynamic> json) {
    final patient = json['patient'] as Map<String, dynamic>?;
    return MedicineReminder(
      id: json['id'] ?? 0,
      patientId: json['patient_id'] as int? ?? patient?['id'] as int? ?? 0,
      medicineName: json['medicine_name'] ?? '',
      dosage: json['dosage'] ?? '',
      timesPerDay: json['times_per_day'] ?? 1,
      reminderTimes: (json['reminder_times'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'])
          : null,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      adherence: json['adherence'] != null
          ? MedicineAdherence.fromJson(json['adherence'])
          : null,
    );
  }

  String get formattedDosage {
    if (dosage.isEmpty) return '';
    return dosage;
  }

  String get frequencyLabel {
    return '${timesPerDay}x daily';
  }

  String get formattedStartDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[startDate.month - 1]} ${startDate.day}, ${startDate.year}';
  }

  String get formattedReminderTimes {
    return reminderTimes.map((time) => _formatTimeString(time)).join(', ');
  }

  String _formatTimeString(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final amPm = hour >= 12 ? 'PM' : 'AM';
      return '$hour12:${minute.toString().padLeft(2, '0')} $amPm';
    } catch (_) {
      return time;
    }
  }

  bool get hasAdherence => adherence != null;

  MedicineReminder copyWith({MedicineAdherence? adherence}) {
    return MedicineReminder(
      id: id,
      patientId: patientId,
      medicineName: medicineName,
      dosage: dosage,
      timesPerDay: timesPerDay,
      reminderTimes: reminderTimes,
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      adherence: adherence ?? this.adherence,
    );
  }

  // ✅ FIXED: Now percentage getter exists in MedicineAdherence
  double get adherencePercentage => adherence?.percentage ?? 0.0;

  int get takenCount => adherence?.taken ?? 0;
  int get skippedCount => adherence?.skipped ?? 0;
  int get pendingCount => adherence?.pending ?? 0;

  // ✅ FIXED: Color based on adherence percentage
  Color get adherenceColor {
    final pct = adherencePercentage;
    if (pct >= 80) return const Color(0xFF226B3F); // Green
    if (pct >= 50) return Colors.orange.shade400;
    return Colors.red.shade400;
  }
}
