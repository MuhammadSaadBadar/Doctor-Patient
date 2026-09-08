// lib/patient/features/doctors/widgets/doctor_availability_card.dart

import 'package:doctor/patient/features/doctors/models/doctor.dart';
import 'package:flutter/material.dart';

class DoctorAvailabilityCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorAvailabilityCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);
    final isAccepting = doctor.doctorProfile?.isAcceptingPatients ?? false;

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
              color: isAccepting
                  ? Colors.green.withValues(alpha: 0.08)
                  : Colors.grey.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isAccepting
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isAccepting ? Colors.green : Colors.grey,
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
                          color: isAccepting
                              ? Colors.green.shade700
                              : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: Text(
                          isAccepting
                              ? 'This doctor is currently taking new patients'
                              : 'This doctor is not currently accepting new patients',
                          style: TextStyle(
                            fontSize: textScale.scale(10).clamp(8.0, 14.0),
                            color: isAccepting
                                ? Colors.green.shade600
                                : Colors.grey.shade600,
                          ),
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
