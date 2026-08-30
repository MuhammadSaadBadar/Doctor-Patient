// lib/patient/features/water_intake/widgets/weekly_history_chart.dart

import 'package:doctor/patient/features/water_intake/models/weekly_water_intake.dart';
import 'package:flutter/material.dart';

class WeeklyHistoryChart extends StatelessWidget {
  final WeeklyWaterIntake? weeklyIntake;
  final int todayGlasses;

  const WeeklyHistoryChart({
    super.key,
    required this.weeklyIntake,
    required this.todayGlasses,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final days =
        weeklyIntake?.days ?? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxValue = weeklyIntake?.maxValue ?? 1;
    final today = DateTime.now().weekday - 1; // Monday = 0

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = (constraints.maxWidth - 48) / 7; // 7 days with spacing
        final chartHeight = constraints.maxHeight > 0 && constraints.maxHeight < double.infinity
            ? constraints.maxHeight
            : 120.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart_rounded,
                  size: 20,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Weekly History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: chartHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(days.length, (index) {
                  final day = days[index];
                  final value = weeklyIntake?.dailyIntake[day] ?? 0;
                  final percentage = maxValue > 0
                      ? (value / maxValue).toDouble()
                      : 0.0;
                  final isToday = index == today;

                  return _buildBarColumn(
                    day: day,
                    percentage: percentage,
                    isToday: isToday,
                    colorScheme: colorScheme,
                    value: value,
                    barWidth: barWidth.clamp(20.0, 40.0),
                    maxHeight: chartHeight * 0.75,
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBarColumn({
    required String day,
    required double percentage,
    required bool isToday,
    required ColorScheme colorScheme,
    required int value,
    required double barWidth,
    required double maxHeight,
  }) {
    final isComplete = percentage >= 1.0;

    return SizedBox(
      width: barWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Bar
          Container(
            width: barWidth * 0.6,
            height: maxHeight * percentage.clamp(0.0, 1.0),
            decoration: BoxDecoration(
              color: isComplete
                  ? colorScheme.tertiary
                  : colorScheme.tertiary.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
              boxShadow: isComplete
                  ? [
                      BoxShadow(
                        color: colorScheme.tertiary.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            day,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              color: isToday
                  ? colorScheme.tertiary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}