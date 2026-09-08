// lib/patient/features/doctors/widgets/doctor_header_card.dart

import 'package:doctor/core/widgets/doctor_avatar.dart';
import 'package:doctor/patient/features/doctors/models/doctor.dart';
import 'package:flutter/material.dart';

class DoctorHeaderCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorHeaderCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final avatarSize = (constraints.maxWidth * 0.2).clamp(60.0, 100.0);
          return Column(
            children: [
              DoctorAvatar(
                imageUrl: doctor.profilePictureUrl ?? doctor.doctorProfilePictureUrl,
                firstName: doctor.firstName,
                lastName: doctor.lastName,
                size: avatarSize,
                enableCacheBusting: true,
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  doctor.fullName,
                  style: TextStyle(
                    fontSize: textScale.scale(20).clamp(16.0, 28.0),
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    fontFamily: 'PlayfairDisplay',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  doctor.doctorProfile?.specialization ?? 'General Practitioner',
                  style: TextStyle(
                    fontSize: textScale.scale(14).clamp(12.0, 18.0),
                    fontWeight: FontWeight.w500,
                    color: colorScheme.secondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * 0.8,
                ),
                child: Flexible(
                  child: Container(
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
                        Flexible(
                          child: Text(
                            doctor.doctorProfile?.isAcceptingPatients ?? false
                                ? 'Accepting New Patients'
                                : 'Not Accepting Patients',
                            style: TextStyle(
                              fontSize: textScale.scale(10).clamp(8.0, 14.0),
                              fontWeight: FontWeight.w500,
                              color: doctor.doctorProfile?.isAcceptingPatients ?? false
                                  ? Colors.green.shade700
                                  : Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (doctor.doctorProfile?.licenseNumber != null) ...[
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'PMDC Verified',
                              style: TextStyle(
                                fontSize: textScale.scale(11).clamp(9.0, 15.0),
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.work_history_rounded,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            doctor.doctorProfile?.yearsOfExperience != null
                                ? '${doctor.doctorProfile!.yearsOfExperience} Years Exp.'
                                : 'N/A',
                            style: TextStyle(
                              fontSize: textScale.scale(11).clamp(9.0, 15.0),
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
