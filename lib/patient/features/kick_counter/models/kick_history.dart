// lib/patient/features/kick_counter/models/kick_history.dart

import 'package:doctor/patient/features/kick_counter/models/kick_session.dart';

class KickHistory {
  final List<KickSession> sessions;
  final int totalCount;
  final bool hasNext;
  final int currentPage;

  KickHistory({
    required this.sessions,
    required this.totalCount,
    required this.hasNext,
    required this.currentPage,
  });

  factory KickHistory.fromJson(Map<String, dynamic> json) {
    final results = json['results'] as List<dynamic>? ?? [];
    final sessions = results
        .map((e) => KickSession.fromJson(e as Map<String, dynamic>))
        .toList();

    return KickHistory(
      sessions: sessions,
      totalCount: json['count'] as int? ?? 0,
      hasNext: json['next'] != null,
      currentPage: 1,
    );
  }

  bool get isEmpty => sessions.isEmpty;

  // Get today's sessions
  List<KickSession> get todaySessions {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return sessions.where((session) {
      final sessionDate = DateTime(
        session.logDate.year,
        session.logDate.month,
        session.logDate.day,
      );
      return sessionDate == today;
    }).toList();
  }

  // Get total kicks today
  int get todayTotalKicks {
    return todaySessions.fold(0, (sum, session) => sum + session.kickCount);
  }

  // Get active session (if any)
  KickSession? get activeSession {
    try {
      return sessions.firstWhere((session) => session.isActive);
    } catch (_) {
      return null;
    }
  }

  // Group sessions by date
  Map<String, List<KickSession>> get groupedByDate {
    final Map<String, List<KickSession>> groups = {};

    for (final session in sessions) {
      final dateKey = session.logDate.toIso8601String().split('T')[0];
      if (!groups.containsKey(dateKey)) {
        groups[dateKey] = [];
      }
      groups[dateKey]!.add(session);
    }

    // Sort each group by time (newest first)
    for (final key in groups.keys) {
      groups[key]!.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    }

    return groups;
  }

  // Get sorted date keys (newest first)
  List<String> get sortedDateKeys {
    final keys = groupedByDate.keys.toList();
    keys.sort((a, b) => b.compareTo(a));
    return keys;
  }

  // Get daily totals
  Map<String, int> get dailyTotals {
    final Map<String, int> totals = {};
    for (final session in sessions) {
      final dateKey = session.logDate.toIso8601String().split('T')[0];
      totals[dateKey] = (totals[dateKey] ?? 0) + session.kickCount;
    }
    return totals;
  }
}
