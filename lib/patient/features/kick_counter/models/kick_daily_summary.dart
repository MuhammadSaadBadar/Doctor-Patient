// lib/patient/features/kick_counter/models/kick_daily_summary.dart

import 'package:doctor/core/localization/translation_keys.dart';
import 'package:doctor/patient/features/kick_counter/models/kick_session.dart';
import 'package:get/get.dart';

class KickDailySummary {
  final String date;
  final DateTime dateTime;
  final int totalKicks;
  final int sessionCount;
  final int? maxSessionKicks;
  final bool hasActiveSession;

  KickDailySummary({
    required this.date,
    required this.dateTime,
    required this.totalKicks,
    required this.sessionCount,
    this.maxSessionKicks,
    this.hasActiveSession = false,
  });

  factory KickDailySummary.fromSessions({
    required String date,
    required List<KickSession> sessions,
  }) {
    final totalKicks = sessions.fold(0, (sum, s) => sum + s.kickCount);
    final activeSessions = sessions.where((s) => s.isActive);
    final maxSessionKicks = sessions.isEmpty
        ? null
        : sessions.map((s) => s.kickCount).reduce((a, b) => a > b ? a : b);

    return KickDailySummary(
      date: date,
      dateTime: DateTime.tryParse(date) ?? DateTime.now(),
      totalKicks: totalKicks,
      sessionCount: sessions.length,
      maxSessionKicks: maxSessionKicks,
      hasActiveSession: activeSessions.isNotEmpty,
    );
  }

  String get displayDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) return TranslationKeys.commonToday.tr;
    if (date == yesterday) return TranslationKeys.commonYesterday.tr;

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
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  String get dayOfWeek {
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[dateTime.weekday - 1];
  }
}
