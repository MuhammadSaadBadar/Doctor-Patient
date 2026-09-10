import 'package:doctor/core/localization/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PatientSosEvent {
  final int id;
  final double? latitude;
  final double? longitude;
  final String status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String notes;

  const PatientSosEvent({
    required this.id,
    this.latitude,
    this.longitude,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    required this.notes,
  });

  factory PatientSosEvent.fromJson(Map<String, dynamic> json) {
    return PatientSosEvent(
      id: (json['id'] as num?)?.toInt() ?? 0,
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      status: json['status'] as String? ?? 'active',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.tryParse(json['resolved_at'].toString()),
      notes: json['notes'] as String? ?? '',
    );
  }

  bool get isActive => status == 'active';

  String get statusLabel {
    switch (status) {
      case 'false_alarm':
        return TranslationKeys.sosStatusFalseAlarm.tr;
      case 'resolved':
        return TranslationKeys.sosStatusResolved.tr;
      default:
        return TranslationKeys.sosStatusActive.tr;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'resolved':
        return Colors.green;
      case 'false_alarm':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
}
