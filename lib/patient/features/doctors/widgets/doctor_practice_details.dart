// lib/patient/features/doctors/widgets/doctor_practice_details.dart

import 'package:doctor/patient/features/doctors/models/doctor.dart';
import 'package:flutter/material.dart';

class DoctorPracticeDetails extends StatelessWidget {
  final Doctor doctor;

  const DoctorPracticeDetails({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
          Text(
            'Professional Details',
            style: TextStyle(
              fontSize: 18,
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
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
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
                      fontSize: 14,
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
                fontSize: isPrice ? 18 : 16,
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
