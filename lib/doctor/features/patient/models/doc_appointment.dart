import 'package:flutter/material.dart';

class Appointment {
  final int id;
  final String scheduledAt;
  final int durationMinutes;
  final String status;
  final String reason;
  final String appointmentType;
  final String doctorName;

  Appointment({
    required this.id,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.status,
    required this.reason,
    required this.appointmentType,
    required this.doctorName,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final doctor = json['doctor'] as Map<String, dynamic>?;
    return Appointment(
      id: json['id'] as int? ?? 0,
      scheduledAt: json['scheduled_at'] as String? ?? '',
      durationMinutes: json['duration_minutes'] as int? ?? 30,
      status: json['status'] as String? ?? 'pending',
      reason: json['reason'] as String? ?? '',
      appointmentType: json['appointment_type'] as String? ?? 'in_person',
      doctorName: doctor != null
          ? 'Dr. ${doctor['first_name'] ?? ''} ${doctor['last_name'] ?? ''}'.trim()
          : 'Unknown Doctor',
    );
  }

  String get formattedDate {
    try {
      final date = DateTime.parse(scheduledAt);
      const months = [
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
      final hour = date.hour > 12 ? date.hour - 12 : date.hour;
      final amPm = date.hour >= 12 ? 'PM' : 'AM';
      final minute = date.minute.toString().padLeft(2, '0');
      return '${months[date.month - 1]} ${date.day}, ${date.year} • $hour:$minute $amPm';
    } catch (_) {
      return scheduledAt;
    }
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmed';
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'no_show':
        return 'No Show';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'no_show':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  bool get isUpcoming {
    try {
      final date = DateTime.parse(scheduledAt);
      return date.isAfter(DateTime.now());
    } catch (_) {
      return false;
    }
  }
}