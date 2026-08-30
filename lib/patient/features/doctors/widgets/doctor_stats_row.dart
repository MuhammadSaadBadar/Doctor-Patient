// lib/patient/features/doctors/widgets/doctor_stats_row.dart

import 'package:doctor/patient/features/doctors/models/doctor.dart';
import 'package:flutter/material.dart';

class DoctorStatsRow extends StatelessWidget {
  final Doctor doctor;

  const DoctorStatsRow({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        _buildStatItem(
          context,
          icon: Icons.groups_rounded,
          label: 'Completed Visits',
          value: doctor.formattedCompletedVisits,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 8),
        _buildStatItem(
          context,
          icon: Icons.star_rounded,
          label: '${doctor.totalRatings ?? 0} Reviews',
          value: doctor.formattedRating,
          color: colorScheme.secondary,
        ),
        const SizedBox(width: 8),
        _buildStatItem(
          context,
          icon: Icons.location_on_rounded,
          label: 'Away',
          value: doctor.distanceKm != null
              ? '${doctor.distanceKm!.toStringAsFixed(1)} km'
              : 'N/A',
          color: colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
