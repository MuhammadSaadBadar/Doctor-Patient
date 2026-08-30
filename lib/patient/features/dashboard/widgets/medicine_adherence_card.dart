// lib/patient/features/dashboard/widgets/medicine_adherence_card.dart

import 'package:flutter/material.dart';
import 'package:doctor/patient/features/dashboard/models/medicine_adherence.dart';

class MedicineAdherenceCard extends StatelessWidget {
  final MedicineAdherence adherence;
  final VoidCallback onTap;

  const MedicineAdherenceCard({
    super.key,
    required this.adherence,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pct = adherence.adherencePercentage;
    final isGood = pct >= 70;
    final progressColor = pct >= 70 ? Colors.green : Colors.orange;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.medication_rounded,
                    size: 18,
                    color: Colors.teal.shade600,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Medicine Adherence',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                Text(
                  '${pct.toInt()}%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: progressColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (pct / 100).clamp(0.0, 1.0),
                backgroundColor: progressColor.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 7,
              ),
            ),
            const SizedBox(height: 14),

            // Stats Row
            Row(
              children: [
                _statItem(
                  cs,
                  icon: Icons.check_circle_rounded,
                  color: Colors.green,
                  value: '${adherence.taken}',
                  label: 'Taken',
                ),
                _statDivider(cs),
                _statItem(
                  cs,
                  icon: Icons.cancel_rounded,
                  color: Colors.red,
                  value: '${adherence.skipped}',
                  label: 'Missed',
                ),
                _statDivider(cs),
                _statItem(
                  cs,
                  icon: Icons.schedule_rounded,
                  color: Colors.blue,
                  value: '${adherence.pending}',
                  label: 'Pending',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(
    ColorScheme cs, {
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statDivider(ColorScheme cs) {
    return Container(width: 1, height: 32, color: cs.outlineVariant);
  }
}
