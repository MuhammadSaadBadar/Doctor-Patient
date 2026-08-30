// lib/patient/features/water_intake/models/today_water_intake.dart

import 'package:doctor/patient/features/water_intake/models/water_intake_entry.dart';

class TodayWaterIntake {
  final String date;
  final int totalMl;
  final List<WaterIntakeEntry> entries;

  TodayWaterIntake({
    required this.date,
    required this.totalMl,
    required this.entries,
  });

  factory TodayWaterIntake.fromJson(Map<String, dynamic> json) {
    final entriesList = (json['entries'] as List<dynamic>? ?? [])
        .map((e) => WaterIntakeEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    return TodayWaterIntake(
      date: json['date'] ?? '',
      totalMl: json['total_ml'] ?? 0,
      entries: entriesList,
    );
  }

  int get glasses => (totalMl / 250).ceil();
  
  // Progress should be calculated against dynamic target (from diet plan)
  double getProgress(int targetMl) => (totalMl / targetMl).clamp(0.0, 1.0);
  
  int getRemainingMl(int targetMl) => (targetMl - totalMl).clamp(0, targetMl);
}