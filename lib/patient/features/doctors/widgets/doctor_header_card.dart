// lib/patient/features/doctors/widgets/doctor_header_card.dart

import 'package:doctor/patient/features/doctors/models/doctor.dart';
import 'package:flutter/material.dart';

class DoctorHeaderCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorHeaderCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: 37,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              child: Text(
                doctor.initials,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            doctor.fullName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              fontFamily: 'PlayfairDisplay',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            doctor.doctorProfile?.specialization ?? 'General Practitioner',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 12),
          // Availability badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: doctor.doctorProfile?.isAcceptingPatients ?? false
                    ? Colors.green.withValues(alpha: 0.12)
                    : Colors.grey.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: doctor.doctorProfile?.isAcceptingPatients ?? false
                        ? Colors.green
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  doctor.doctorProfile?.isAcceptingPatients ?? false
                      ? 'Accepting New Patients'
                      : 'Not Accepting Patients',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: doctor.doctorProfile?.isAcceptingPatients ?? false
                        ? Colors.green.shade700
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Verified & Experience
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (doctor.doctorProfile?.licenseNumber != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'PMDC Verified',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
              ],
              Row(
                children: [
                  Icon(
                    Icons.work_history_rounded,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    doctor.doctorProfile?.yearsOfExperience != null
                        ? '${doctor.doctorProfile!.yearsOfExperience} Years Exp.'
                        : 'N/A',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
