// lib/patient/features/medicine_reminders/widgets/reminder_time_chip.dart

import 'package:flutter/material.dart';

class ReminderTimeChip extends StatelessWidget {
  final String time;
  final VoidCallback onRemove;

  const ReminderTimeChip({
    super.key,
    required this.time,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        // ✅ Dark: primary-tinted; Light: neutral surface
        color: isDark
            ? cs.primary.withValues(alpha: 0.12)
            : cs.surfaceContainer,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark
              ? cs.primary.withValues(alpha: 0.25)
              : cs.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 16, color: cs.primary),
          const SizedBox(width: 6),
          Text(
            time,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              // ✅ onSurface reads better than onSurfaceVariant in dark
              color: isDark ? cs.onSurface : cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: isDark ? cs.onSurfaceVariant : cs.outline,
            ),
          ),
        ],
      ),
    );
  }
}
