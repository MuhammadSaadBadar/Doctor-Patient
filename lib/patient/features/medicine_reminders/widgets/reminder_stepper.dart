// lib/patient/features/medicine_reminders/widgets/reminder_stepper.dart

import 'package:flutter/material.dart';

class ReminderStepper extends StatelessWidget {
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const ReminderStepper({
    super.key,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        GestureDetector(
          onTap: onDecrement,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.04),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Icon(
              Icons.remove_rounded,
              size: 18,
              color: colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onIncrement,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              Icons.add_rounded,
              size: 18,
              color: colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
