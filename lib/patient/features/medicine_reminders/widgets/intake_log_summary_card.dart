// lib/patient/features/medicine_reminders/widgets/intake_log_summary_card.dart

import 'package:flutter/material.dart';

class IntakeLogSummaryCard extends StatelessWidget {
  final int taken;
  final int skipped;
  final int pending;
  final double adherenceRate;

  const IntakeLogSummaryCard({
    super.key,
    required this.taken,
    required this.skipped,
    required this.pending,
    required this.adherenceRate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Adherence Rate
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adherence Rate',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${adherenceRate.toInt()}%',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                    fontFamily: 'PlayfairDisplay',
                  ),
                ),
              ],
            ),
          ),
          // Stats
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _buildStatItem(
                  context,
                  label: 'Taken',
                  count: taken,
                  color: Colors.green,
                ),
                _buildStatItem(
                  context,
                  label: 'Skipped',
                  count: skipped,
                  color: Colors.orange,
                ),
                _buildStatItem(
                  context,
                  label: 'Pending',
                  count: pending,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required int count,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
