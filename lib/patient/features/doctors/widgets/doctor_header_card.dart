// lib/patient/features/doctors/widgets/doctor_header_card.dart

import 'package:doctor/core/widgets/doctor_avatar.dart';
import 'package:doctor/patient/features/doctors/models/doctor.dart';
import 'package:flutter/material.dart';

class DoctorHeaderCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorHeaderCard({super.key, required this.doctor});

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
      padding: const EdgeInsets.all(20),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final avatarSize = (constraints.maxWidth * 0.2).clamp(60.0, 100.0);
          return Column(
            children: [
              DoctorAvatar(
                imageUrl:
                    doctor.profilePictureUrl ?? doctor.doctorProfilePictureUrl,
                firstName: doctor.firstName,
                lastName: doctor.lastName,
                size: avatarSize,
                enableCacheBusting: true,
              ),
              const SizedBox(height: 12),
              Text(
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
              const SizedBox(height: 4),
              Text(
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
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * 0.8,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    // ✅ Semantic tints that flip with brightness
                    color: isAccepting
                        ? Colors.green.withValues(alpha: isDark ? 0.20 : 0.12)
                        : colorScheme.onSurfaceVariant.withValues(
                            alpha: isDark ? 0.18 : 0.12,
                          ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isAccepting ? acceptingFg : notAcceptingFg,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          isAccepting
                              ? 'Accepting New Patients'
                              : 'Not Accepting Patients',
                          style: TextStyle(
                            fontSize: textScale.scale(10).clamp(8.0, 14.0),
                            fontWeight: FontWeight.w500,
                            color: isAccepting ? acceptingFg : notAcceptingFg,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (doctor.doctorProfile?.licenseNumber != null) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
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
                            fontSize: textScale.scale(11).clamp(9.0, 15.0),
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                  ],
                  Row(
                    mainAxisSize: MainAxisSize.min,
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
                          fontSize: textScale.scale(11).clamp(9.0, 15.0),
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
