// lib/patient/features/doctors/widgets/doctor_location_card.dart

import 'package:doctor/patient/features/doctors/models/doctor.dart';
import 'package:flutter/material.dart';

class DoctorLocationCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorLocationCard({super.key, required this.doctor});

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = _isDark(context);
    final textScale = MediaQuery.textScalerOf(context);
    final profile = doctor.doctorProfile;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ✅ Gradient-in-dark, solid-in-light
        gradient: isDark
            ? LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [
                  colorScheme.primary.withValues(alpha: 0.10),
                  colorScheme.primaryContainer.withValues(alpha: 0.06),
                ],
              )
            : null,
        color: !isDark ? colorScheme.surfaceContainerLowest : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? colorScheme.primary.withValues(alpha: 0.12)
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
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
          Text(
            profile?.area ?? 'Area not specified',
            style: TextStyle(
              fontSize: textScale.scale(14).clamp(12.0, 18.0),
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            profile?.city ?? 'City not specified',
            style: TextStyle(
              fontSize: textScale.scale(12).clamp(10.0, 16.0),
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (doctor.distanceKm != null) ...[
            const SizedBox(height: 6),
            Text(
              '${doctor.distanceKm!.toStringAsFixed(1)} km away from your location',
              style: TextStyle(
                fontSize: textScale.scale(10).clamp(8.0, 14.0),
                fontWeight: FontWeight.w500,
                color: colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
