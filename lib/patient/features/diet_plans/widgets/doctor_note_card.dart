// lib/patient/features/diet_plans/widgets/doctor_note_card.dart

import 'package:flutter/material.dart';

class DoctorNoteCard extends StatelessWidget {
  final String notes;

  const DoctorNoteCard({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note_alt_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                "Doctor's Note",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: colorScheme.primary,
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
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
