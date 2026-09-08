// lib/patient/features/doctors/widgets/doctor_location_card.dart

import 'package:doctor/patient/features/doctors/models/doctor.dart';
import 'package:flutter/material.dart';

class DoctorLocationCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorLocationCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);
    final profile = doctor.doctorProfile;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 20,
                color: colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Practice Location',
                style: TextStyle(
                  fontSize: textScale.scale(16).clamp(14.0, 20.0),
                  fontWeight: FontWeight.w600,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Flexible(
            child: Text(
              profile?.area ?? 'Area not specified',
              style: TextStyle(
                fontSize: textScale.scale(14).clamp(12.0, 18.0),
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              profile?.city ?? 'City not specified',
              style: TextStyle(
                fontSize: textScale.scale(12).clamp(10.0, 16.0),
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (doctor.distanceKm != null) ...[
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                '${doctor.distanceKm!.toStringAsFixed(1)} km away from your location',
                style: TextStyle(
                  fontSize: textScale.scale(10).clamp(8.0, 14.0),
                  fontWeight: FontWeight.w500,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
