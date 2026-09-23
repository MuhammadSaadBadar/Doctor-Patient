// lib/patient/features/doctors/widgets/doctor_practice_details.dart

import 'package:doctor/patient/features/doctors/models/doctor.dart';
import 'package:flutter/material.dart';

class DoctorPracticeDetails extends StatelessWidget {
  final Doctor doctor;

  const DoctorPracticeDetails({super.key, required this.doctor});

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
          Text(
            'Professional Details',
            style: TextStyle(
              fontSize: textScale.scale(16).clamp(14.0, 20.0),
              fontWeight: FontWeight.w600,
              color: colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            icon: Icons.medical_services_rounded,
            label: 'Specialization',
            value: profile?.specialization ?? 'N/A',
          ),
          _buildDetailRow(
            context,
            icon: Icons.badge_rounded,
            label: 'License Number',
            value: profile?.licenseNumber ?? 'N/A',
          ),
          _buildDetailRow(
            context,
            icon: Icons.payments_rounded,
            label: 'Consultation Fee',
            value: profile?.formattedFee ?? 'Free',
            isPrice: true,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isPrice = false,
    bool isLast = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = _isDark(context);
    final textScale = MediaQuery.textScalerOf(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  // ✅ Stronger divider in dark
                  color: isDark
                      ? colorScheme.primary.withValues(alpha: 0.12)
                      : colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: textScale.scale(12).clamp(10.0, 16.0),
                      color: colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: textScale
                    .scale(isPrice ? 16 : 12)
                    .clamp(isPrice ? 14.0 : 10.0, isPrice ? 22.0 : 16.0),
                fontWeight: isPrice ? FontWeight.w700 : FontWeight.w500,
                color: isPrice ? colorScheme.primary : colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
