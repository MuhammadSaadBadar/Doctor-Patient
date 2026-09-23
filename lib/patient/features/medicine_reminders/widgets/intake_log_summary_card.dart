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

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _semanticFg(BuildContext context, Color base) {
    final isDark = _isDark(context);
    if (base == Colors.green)
      return isDark ? Colors.green.shade300 : Colors.green.shade800;
    if (base == Colors.orange)
      return isDark ? Colors.orange.shade300 : Colors.orange.shade800;
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ✅ Gradient in dark
        gradient: isDark
            ? LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [
                  cs.primary.withOpacity(0.10),
                  cs.primaryContainer.withOpacity(0.06),
                ],
              )
            : null,
        color: !isDark ? cs.surfaceContainerLowest : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? cs.primary.withOpacity(0.12)
              : cs.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: cs.shadow.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
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
                    color: cs.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${adherenceRate.toInt()}%',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                    fontFamily: 'PlayfairDisplay',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _buildStatItem(
                  context,
                  label: 'Taken',
                  count: taken,
                  // ✅ Semantic green
                  color: _semanticFg(context, Colors.green),
                ),
                _buildStatItem(
                  context,
                  label: 'Skipped',
                  count: skipped,
                  // ✅ Semantic orange
                  color: _semanticFg(context, Colors.orange),
                ),
                _buildStatItem(
                  context,
                  label: 'Pending',
                  count: pending,
                  color: cs.primary,
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
    final cs = Theme.of(context).colorScheme;

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
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
