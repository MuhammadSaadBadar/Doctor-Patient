// lib/patient/features/medicine_reminders/widgets/reminder_empty_state.dart

import 'package:flutter/material.dart';

class ReminderEmptyState extends StatelessWidget {
  final VoidCallback onAddTap;

  const ReminderEmptyState({super.key, required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                // ✅ Stronger tint in dark
                color: cs.primary.withOpacity(isDark ? 0.18 : 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medication_rounded,
                size: 40,
                color: cs.primary.withOpacity(isDark ? 0.7 : 0.4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Medicine Reminders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
                fontFamily: 'PlayfairDisplay',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first medicine reminder to stay on track',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAddTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, size: 18),
                  const SizedBox(width: 6),
                  const Text('Add Reminder'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
