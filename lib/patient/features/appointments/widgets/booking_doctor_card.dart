// lib/patient/features/appointments/widgets/booking_doctor_card.dart

import 'package:doctor/patient/features/doctors/models/doctor.dart';
import 'package:flutter/material.dart';

class BookingDoctorCard extends StatelessWidget {
  final Doctor doctor;

  const BookingDoctorCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ✅ Dark: stronger gradient; Light: subtle (unchanged)
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: isDark
              ? [
                  colorScheme.primary.withValues(alpha: 0.14),
                  colorScheme.primaryContainer.withValues(alpha: 0.08),
                ]
              : [
                  colorScheme.primary.withValues(alpha: 0.06),
                  colorScheme.primary.withValues(alpha: 0.02),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? colorScheme.primary.withValues(alpha: 0.25)
              : colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.maxWidth * 0.18;
              final avatarSize = size.clamp(48.0, 64.0);
              final fontSize = textScale
                  .scale(avatarSize * 0.4)
                  .clamp(18.0, 26.0);
              return Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(
                        alpha: isDark ? 0.35 : 0.2,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    doctor.firstName.isNotEmpty
                        ? doctor.firstName[0].toUpperCase()
                        : 'D',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.fullName,
                  style: TextStyle(
                    fontSize: textScale.scale(16).clamp(14.0, 18.0),
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  doctor.doctorProfile?.specialization ?? 'Specialist',
                  style: TextStyle(
                    fontSize: textScale.scale(13).clamp(11.0, 14.0),
                    fontWeight: FontWeight.w500,
                    // ✅ Dark: bright pink; Light: primary (unchanged)
                    color: isDark
                        ? colorScheme.primaryFixed
                        : colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(
                            alpha: isDark ? 0.18 : 0.12,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Colors.amber.shade600,
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                doctor.averageRating?.toStringAsFixed(1) ??
                                    'N/A',
                                style: TextStyle(
                                  fontSize: textScale
                                      .scale(11)
                                      .clamp(9.0, 12.0),
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                ' (${doctor.totalRatings ?? 0})',
                                style: TextStyle(
                                  fontSize: textScale
                                      .scale(10)
                                      .clamp(8.0, 11.0),
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(
                            alpha: isDark ? 0.18 : 0.12,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.green.shade400
                                    : Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Available',
                                style: TextStyle(
                                  fontSize: textScale
                                      .scale(10)
                                      .clamp(8.0, 11.0),
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.green.shade300
                                      : Colors.green.shade700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
