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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            time,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
