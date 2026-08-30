// lib/patient/features/doctors/widgets/doctor_location_card.dart

import 'package:doctor/patient/features/doctors/models/doctor.dart';
import 'package:flutter/material.dart';

class DoctorLocationCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorLocationCard({super.key, required this.doctor});

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
                  fontSize: 18,
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
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            profile?.city ?? 'City not specified',
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
          if (doctor.distanceKm != null) ...[
            const SizedBox(height: 6),
            Text(
              '${doctor.distanceKm!.toStringAsFixed(1)} km away from your location',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.primary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Map Placeholder
          // Container(
          //   height: 120,
          //   width: double.infinity,
          //   decoration: BoxDecoration(
          //     color: colorScheme.primary.withValues(alpha: 0.05),
          //     borderRadius: BorderRadius.circular(12),
          //     border: Border.all(
          //       color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          //     ),
          //   ),
          //   child: Center(
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Icon(
          //           Icons.map_rounded,
          //           size: 32,
          //           color: colorScheme.primary.withOpacity(0.3),
          //         ),
          //         const SizedBox(height: 4),
          //         Text(
          //           'Map View',
          //           style: TextStyle(
          //             fontSize: 12,
          //             color: colorScheme.primary.withOpacity(0.3),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 12),
          // SizedBox(
          //   width: double.infinity,
          //   child: OutlinedButton(
          //     onPressed: () {
          //       // Open maps with location
          //       _openMaps(doctor);
          //     },
          //     style: OutlinedButton.styleFrom(
          //       foregroundColor: colorScheme.secondary,
          //       side: BorderSide(color: colorScheme.secondary),
          //       padding: const EdgeInsets.symmetric(vertical: 12),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(30),
          //       ),
          //     ),
          //     child: const Text('Get Directions'),
          //   ),
          // ),
        ],
      ),
    );
  }

  void _openMaps(Doctor doctor) {
    // Implementation depends on device
    // Can use url_launcher to open Google Maps or Apple Maps
  }
}
