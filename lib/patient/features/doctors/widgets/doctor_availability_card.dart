// lib/patient/features/doctors/widgets/doctor_availability_card.dart

import 'package:doctor/patient/features/doctors/models/doctor.dart';
import 'package:flutter/material.dart';

class DoctorAvailabilityCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorAvailabilityCard({super.key, required this.doctor});

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _semanticFg(BuildContext context, Color base) {
    final isDark = _isDark(context);
    if (base == Colors.green)
      return isDark ? Colors.green.shade300 : Colors.green.shade800;
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = _isDark(context);
    final textScale = MediaQuery.textScalerOf(context);
    final isAccepting = doctor.doctorProfile?.isAcceptingPatients ?? false;

    final acceptingFg = _semanticFg(context, Colors.green);
    final notAcceptingFg = colorScheme.onSurfaceVariant;

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
                Icons.schedule_rounded,
                size: 20,
                color: colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Availability',
                style: TextStyle(
                  fontSize: textScale.scale(16).clamp(14.0, 20.0),
                  fontWeight: FontWeight.w600,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // ✅ Semantic tint that flips with brightness
              color: isAccepting
                  ? Colors.green.withValues(alpha: isDark ? 0.18 : 0.08)
                  : colorScheme.onSurfaceVariant.withValues(
                      alpha: isDark ? 0.14 : 0.08,
                    ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isAccepting
                    ? Colors.green.withValues(alpha: isDark ? 0.45 : 0.2)
                    : colorScheme.onSurfaceVariant.withValues(
                        alpha: isDark ? 0.35 : 0.2,
                      ),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isAccepting ? acceptingFg : notAcceptingFg,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAccepting
                            ? 'Accepting New Patients'
                            : 'Not Accepting Patients',
                        style: TextStyle(
                          fontSize: textScale.scale(14).clamp(12.0, 18.0),
                          fontWeight: FontWeight.w600,
                          color: isAccepting ? acceptingFg : notAcceptingFg,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAccepting
                            ? 'This doctor is currently taking new patients'
                            : 'This doctor is not currently accepting new patients',
                        style: TextStyle(
                          fontSize: textScale.scale(10).clamp(8.0, 14.0),
                          color: (isAccepting ? acceptingFg : notAcceptingFg)
                              .withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
