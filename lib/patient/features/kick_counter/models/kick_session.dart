// lib/patient/features/kick_counter/models/kick_session.dart

import 'package:doctor/core/localization/translation_keys.dart';
import 'package:doctor/patient/features/kick_counter/models/kick_event.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KickSession {
  final int id;
  final int patientId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int kickCount;
  final DateTime logDate;
  final List<KickEvent> events;
  final DateTime createdAt;

  KickSession({
    required this.id,
    required this.patientId,
    required this.startedAt,
    this.endedAt,
    required this.kickCount,
    required this.logDate,
    required this.events,
    required this.createdAt,
  });

  factory KickSession.fromJson(Map<String, dynamic> json) {
    final eventsList = (json['events'] as List<dynamic>? ?? [])
        .map((e) => KickEvent.fromJson(e as Map<String, dynamic>))
        .toList();

    return KickSession(
      id: json['id'] ?? 0,
      patientId: json['patient']?['id'] ?? 0,
      startedAt: DateTime.tryParse(json['started_at'] ?? '') ?? DateTime.now(),
      endedAt: json['ended_at'] != null
          ? DateTime.tryParse(json['ended_at'])
          : null,
      kickCount: json['kick_count'] ?? 0,
      logDate: DateTime.tryParse(json['log_date'] ?? '') ?? DateTime.now(),
      events: eventsList,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  bool get isActive => endedAt == null;

  KickSession copyWith({
    int? id,
    int? patientId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? kickCount,
    DateTime? logDate,
    List<KickEvent>? events,
    DateTime? createdAt,
  }) {
    return KickSession(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      kickCount: kickCount ?? this.kickCount,
      logDate: logDate ?? this.logDate,
      events: events ?? this.events,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get duration {
    if (endedAt == null) {
      final diff = DateTime.now().difference(startedAt);
      return _formatDuration(diff);
    }
    final diff = endedAt!.difference(startedAt);
    return _formatDuration(diff);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')} min';
  }

  String get statusLabel {
    if (endedAt != null) return TranslationKeys.kickCounterCompleted.tr;
    return TranslationKeys.kickCounterActive.tr;
  }

  Color get statusColor {
    if (endedAt != null) return Colors.green;
    return Colors.orange;
  }
}
