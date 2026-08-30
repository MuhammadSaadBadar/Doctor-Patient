// lib/features/emergency/models/sos_event.dart

import 'package:doctor/core/constants/color_constants.dart';
import 'package:flutter/material.dart';

/// SOS event status enum
enum SosStatus { active, resolved, falseAlarm }

extension SosStatusExtension on SosStatus {
  String get displayName {
    switch (this) {
      case SosStatus.active:
        return 'Active';
      case SosStatus.resolved:
        return 'Resolved';
      case SosStatus.falseAlarm:
        return 'False Alarm';
    }
  }

  Color get color {
    switch (this) {
      case SosStatus.active:
        return AppColors.error;
      case SosStatus.resolved:
        return Colors.green;
      case SosStatus.falseAlarm:
        return AppColors.onSurfaceVariant;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case SosStatus.active:
        return AppColors.errorContainer;
      case SosStatus.resolved:
        return Colors.green.withOpacity(0.12);
      case SosStatus.falseAlarm:
        return AppColors.surfaceVariant;
    }
  }

  IconData get icon {
    switch (this) {
      case SosStatus.active:
        return Icons.emergency_rounded;
      case SosStatus.resolved:
        return Icons.check_circle_rounded;
      case SosStatus.falseAlarm:
        return Icons.block_rounded;
    }
  }
}

/// SOS Event model
class SosEvent {
  final String id;
  final int patientId;
  final String patientName;
  final String patientInitials;
  final String patientEmail;
  final String? patientPhone;
  final String? patientBloodGroup;
  final String? patientAllergies;
  final double? latitude;
  final double? longitude;
  final String? location;
  final SosStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolvedBy;

  SosEvent({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientInitials,
    required this.patientEmail,
    this.patientPhone,
    this.patientBloodGroup,
    this.patientAllergies,
    this.latitude,
    this.longitude,
    this.location,
    required this.status,
    this.notes,
    required this.createdAt,
    this.resolvedAt,
    this.resolvedBy,
  });

  factory SosEvent.fromJson(Map<String, dynamic> json) {
    final patient = json['patient'] as Map<String, dynamic>? ?? {};
    final statusStr = json['status'] as String? ?? 'active';

    return SosEvent(
      id: json['id'].toString(),
      patientId: patient['id'] as int? ?? 0,
      patientName:
          '${patient['first_name'] ?? ''} ${patient['last_name'] ?? ''}'.trim(),
      patientInitials: _getInitials(
        patient['first_name'] ?? '',
        patient['last_name'] ?? '',
      ),
      patientEmail: patient['email'] ?? '',
      patientPhone: patient['phone_number'] as String?,
      patientBloodGroup: patient['patient_profile']?['blood_group'] as String?,
      patientAllergies: patient['patient_profile']?['allergies'] as String?,
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      location: _formatLocation(json['latitude'], json['longitude']),
      status: _parseStatus(statusStr),
      notes: json['notes'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.tryParse(json['resolved_at'])
          : null,
      resolvedBy: json['resolved_by'] as String?,
    );
  }

  static String _getInitials(String firstName, String lastName) {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  static SosStatus _parseStatus(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return SosStatus.active;
      case 'resolved':
        return SosStatus.resolved;
      case 'false_alarm':
        return SosStatus.falseAlarm;
      default:
        return SosStatus.active;
    }
  }

  static String _formatLocation(dynamic lat, dynamic lng) {
    if (lat != null && lng != null) {
      try {
        final latVal = double.tryParse(lat.toString());
        final lngVal = double.tryParse(lng.toString());
        if (latVal != null && lngVal != null) {
          return '${latVal.toStringAsFixed(4)}° N, ${lngVal.toStringAsFixed(4)}° E';
        }
      } catch (_) {}
    }
    return 'Location not available';
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays > 7) {
      return '${diff.inDays ~/ 7}w ago';
    } else if (diff.inDays > 0) {
      return diff.inDays == 1 ? 'Yesterday' : '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return diff.inHours == 1 ? '1 hour ago' : '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return diff.inMinutes == 1 ? '1 min ago' : '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Check if event is active
  bool get isActive => status == SosStatus.active;

  /// Get formatted date string
  String get formattedDate {
    return '${_monthName(createdAt.month)} ${createdAt.day}, ${createdAt.year}, ${_formatTime(createdAt)}';
  }

  String _monthName(int month) {
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
    return months[month - 1];
  }

  String _formatTime(DateTime date) {
    final hour = date.hour == 0
        ? 12
        : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  /// Get time string for display
  String get timeDisplay {
    return '${_formatTime(createdAt)}';
  }

  /// Get date string for display
  String get dateDisplay {
    return '${_monthName(createdAt.month)} ${createdAt.day}, ${createdAt.year}';
  }

  /// Get full date time display
  String get dateTimeDisplay {
    return '$dateDisplay, $timeDisplay';
  }

  /// Get resolved time display
  String get resolvedTimeDisplay {
    if (resolvedAt == null) return '';
    final hour = resolvedAt!.hour == 0
        ? 12
        : (resolvedAt!.hour > 12 ? resolvedAt!.hour - 12 : resolvedAt!.hour);
    final minute = resolvedAt!.minute.toString().padLeft(2, '0');
    final ampm = resolvedAt!.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  /// Get resolved date display
  String get resolvedDateDisplay {
    if (resolvedAt == null) return '';
    return '${_monthName(resolvedAt!.month)} ${resolvedAt!.day}, ${resolvedAt!.year}';
  }

  /// Get full resolved date time display
  String get resolvedDateTimeDisplay {
    if (resolvedAt == null) return '';
    return '$resolvedDateDisplay, $resolvedTimeDisplay';
  }
}

/// Paginated SOS event list result
class SosEventListResult {
  final List<SosEvent> events;
  final int totalCount;
  final bool hasNext;

  SosEventListResult({
    required this.events,
    required this.totalCount,
    required this.hasNext,
  });
}
