// lib/patient/features/medicine_reminders/widgets/reminder_empty_state.dart

import 'package:flutter/material.dart';

class ReminderEmptyState extends StatelessWidget {
  final VoidCallback onAddTap;

  const ReminderEmptyState({super.key, required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                color: colorScheme.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medication_rounded,
                size: 40,
                color: colorScheme.primary.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Medicine Reminders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                fontFamily: 'PlayfairDisplay',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first medicine reminder to stay on track',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAddTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
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
                  Icon(Icons.add_rounded, size: 18),
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
