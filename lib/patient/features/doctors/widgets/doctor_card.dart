// lib/patient/features/doctors/widgets/doctor_card.dart

import 'package:doctor/core/widgets/doctor_avatar.dart';
import 'package:doctor/patient/features/doctors/models/doctor.dart';
import 'package:flutter/material.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;
  final VoidCallback onBookTap;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onTap,
    required this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // ✅ Prevents unbounded height issues
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DoctorAvatar(
                  imageUrl:
                      doctor.profilePictureUrl ??
                      doctor.doctorProfilePictureUrl,
                  firstName: doctor.firstName,
                  lastName: doctor.lastName,
                  size: 64,
                  enableCacheBusting: true,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // ✅ Added
                    children: [
                      Text(
                        // ✅ Removed Flexible wrapper
                        doctor.fullName,
                        style: TextStyle(
                          fontSize: textScale.scale(14).clamp(12.0, 18.0),
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (doctor.doctorProfile?.hasSpecialization ?? false)
                        Text(
                          // ✅ Removed Flexible wrapper
                          doctor.doctorProfile!.specialization!,
                          style: TextStyle(
                            fontSize: textScale.scale(11).clamp(9.0, 14.0),
                            fontWeight: FontWeight.w600,
                            color: colorScheme.secondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            // ✅ Removed Flexible wrapper
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  doctor.formattedRating,
                                  style: TextStyle(
                                    fontSize: textScale
                                        .scale(10)
                                        .clamp(8.0, 14.0),
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            // ✅ Removed Flexible wrapper
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.workspace_premium_rounded,
                                size: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                // ✅ Removed Flexible wrapper
                                doctor.doctorProfile?.experienceDisplay ??
                                    'N/A',
                                style: TextStyle(
                                  fontSize: textScale
                                      .scale(10)
                                      .clamp(8.0, 14.0),
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: doctor.isAcceptingPatients
                                ? Colors.green
                                : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            // ✅ Removed Flexible wrapper
                            doctor.isAcceptingPatients
                                ? 'Accepting Patients'
                                : 'Not Accepting',
                            style: TextStyle(
                              fontSize: textScale.scale(10).clamp(8.0, 14.0),
                              fontWeight: FontWeight.w600,
                              color: doctor.isAcceptingPatients
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: doctor.doctorProfile?.formattedFee ?? 'Free',
                          style: TextStyle(
                            fontSize: textScale.scale(16).clamp(14.0, 22.0),
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        TextSpan(
                          text: doctor.doctorProfile?.consultationFee != null
                              ? '/visit'
                              : '',
                          style: TextStyle(
                            fontSize: textScale.scale(10).clamp(8.0, 14.0),
                            fontWeight: FontWeight.w400,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onBookTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(
                      horizontal: textScale.scale(16).clamp(12.0, 24.0),
                      vertical: textScale.scale(8).clamp(6.0, 14.0),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Book',
                    style: TextStyle(
                      fontSize: textScale.scale(11).clamp(9.0, 14.0),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
