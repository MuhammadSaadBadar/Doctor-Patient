// lib/patient/features/diet_plans/widgets/doctor_note_card.dart

import 'package:flutter/material.dart';

class DoctorNoteCard extends StatelessWidget {
  final String notes;

  const DoctorNoteCard({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        // ✅ Dark: primary-tinted gradient to match other cards
        // ✅ Light: surfaceContainerLow (subtle neutral)
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
        color: !isDark ? cs.surfaceContainerLow : null,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? cs.primary.withOpacity(0.12)
              : cs.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_alt_rounded, size: 20, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                "Doctor's Note",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            notes,
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
