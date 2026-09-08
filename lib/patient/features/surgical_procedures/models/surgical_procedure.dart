// lib/patient/features/surgical_procedures/models/surgical_procedure.dart

import 'dart:ui';

import 'package:flutter/material.dart';

class SurgicalProcedure {
  final int id;
  final int patientId;
  final String procedureName;
  final DateTime procedureDate;
  final String? hospitalName;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  SurgicalProcedure({
    required this.id,
    required this.patientId,
    required this.procedureName,
    required this.procedureDate,
    this.hospitalName,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SurgicalProcedure.fromJson(Map<String, dynamic> json) {
    return SurgicalProcedure(
      id: json['id'] ?? 0,
      patientId: json['patient']?['id'] ?? 0,
      procedureName: json['procedure_name'] ?? '',
      procedureDate:
          DateTime.tryParse(json['procedure_date'] ?? '') ?? DateTime.now(),
      hospitalName: json['hospital_name'],
      notes: json['notes'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'procedure_name': procedureName,
      'procedure_date': procedureDate.toIso8601String().split('T')[0],
      'hospital_name': hospitalName,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get formattedDate {
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
    return '${months[procedureDate.month - 1]} ${procedureDate.day}, ${procedureDate.year}';
  }

  String get category {
    final name = procedureName.toLowerCase();
    if (name.contains('cesarean') ||
        name.contains('c-section') ||
        name.contains('delivery')) {
      return 'Obstetric';
    }
    if (name.contains('appendectomy') ||
        name.contains('laparoscopic') ||
        name.contains('hernia')) {
      return 'General';
    }
    if (name.contains('hysterectomy') ||
        name.contains('ovarian') ||
        name.contains('fibroid')) {
      return 'Gynecological';
    }
    return 'Other';
  }

  IconData get categoryIcon {
    switch (category) {
      case 'Obstetric':
        return Icons.pregnant_woman_rounded;
      case 'General':
        return Icons.local_hospital_rounded;
      case 'Gynecological':
        return Icons.female_rounded;
      default:
        return Icons.medical_services_rounded;
    }
  }

  Color get categoryColor {
    switch (category) {
      case 'Obstetric':
        return const Color(0xFFE88B9C);
      case 'General':
        return const Color(0xFF8BA7E8);
      case 'Gynecological':
        return const Color(0xFF8455EE);
      default:
        return const Color(0xFFA8B69F);
    }
  }
}
