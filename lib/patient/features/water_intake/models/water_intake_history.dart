// lib/patient/features/water_intake/models/water_intake_history.dart

import 'package:doctor/patient/features/water_intake/models/water_intake_entry.dart';

class WaterIntakeHistory {
  final List<WaterIntakeEntry> entries;
  final int totalCount;
  final bool hasNext;
  int currentPage;

  WaterIntakeHistory({
    required this.entries,
    required this.totalCount,
    required this.hasNext,
    this.currentPage = 1,
  });

  factory WaterIntakeHistory.fromJson(Map<String, dynamic> json) {
    final results = json['results'] as List<dynamic>? ?? [];
    final entries = results
        .map((e) => WaterIntakeEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    return WaterIntakeHistory(
      entries: entries,
      totalCount: json['count'] as int? ?? 0,
      hasNext: json['next'] != null,
      currentPage: 1, // Will be set by the repository
    );
  }

  // Group entries by date
  Map<String, List<WaterIntakeEntry>> get groupedByDate {
    final Map<String, List<WaterIntakeEntry>> groups = {};

    for (final entry in entries) {
      final dateKey = entry.logDate.toIso8601String().split('T')[0];
      if (!groups.containsKey(dateKey)) {
        groups[dateKey] = [];
      }
      groups[dateKey]!.add(entry);
    }

    // Sort each group by time (newest first)
    for (final key in groups.keys) {
      groups[key]!.sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    }

    return groups;
  }

  // Get daily totals
  Map<String, int> get dailyTotals {
    final Map<String, int> totals = {};
    for (final entry in entries) {
      final dateKey = entry.logDate.toIso8601String().split('T')[0];
      totals[dateKey] = (totals[dateKey] ?? 0) + entry.amountMl;
    }
    return totals;
  }

  // Get sorted date keys (newest first)
  List<String> get sortedDateKeys {
    final keys = groupedByDate.keys.toList();
    keys.sort((a, b) => b.compareTo(a));
    return keys;
  }

  bool get isEmpty => entries.isEmpty;
}
