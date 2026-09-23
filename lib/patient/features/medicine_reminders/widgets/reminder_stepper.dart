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

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    return Row(
      children: [
        // ─────────────────────────────────────────────
        // Minus button — tinted, NOT a surface token
        // ─────────────────────────────────────────────
        GestureDetector(
          onTap: onDecrement,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              // ✅ Dark: primary-tinted circle; Light: neutral surface
              color: isDark ? cs.primary.withValues(alpha: 0.15) : cs.surface,
              shape: BoxShape.circle,
              border: isDark
                  ? Border.all(
                      color: cs.primary.withValues(alpha: 0.30),
                      width: 1,
                    )
                  : null,
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: cs.shadow.withValues(alpha: 0.04),
                        blurRadius: 4,
                      ),
                    ],
            ),
            child: Icon(Icons.remove_rounded, size: 18, color: cs.primary),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(width: 12),

        // ─────────────────────────────────────────────
        // Plus button — solid primary
        // ─────────────────────────────────────────────
        GestureDetector(
          onTap: onIncrement,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: isDark ? 0.45 : 0.30),
                  blurRadius: isDark ? 10 : 8,
                ),
              ],
            ),
            child: Icon(Icons.add_rounded, size: 18, color: cs.onPrimary),
          ),
        ),
      ],
    );
  }
}
