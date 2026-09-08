// lib/patient/features/doctors/widgets/doctor_address_card.dart

import 'package:flutter/material.dart';

class DoctorAddressCard extends StatelessWidget {
  final String? area;
  final String? city;
  final double? latitude;
  final double? longitude;

  const DoctorAddressCard({
    super.key,
    this.area,
    this.city,
    this.latitude,
    this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    final hasLocation =
        area != null && area!.isNotEmpty && city != null && city!.isNotEmpty;

    if (!hasLocation) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
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
        mainAxisSize:
            MainAxisSize.min, // ✅ Critical: Prevents unbounded height issues
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Clinic Address',
                style: TextStyle(
                  fontSize: textScale.scale(13).clamp(11.0, 16.0),
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Address - Area
          if (area != null && area!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_city_rounded,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      area!,
                      style: TextStyle(
                        fontSize: textScale.scale(13).clamp(11.0, 16.0),
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // City
          if (city != null && city!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_city_rounded,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      city!,
                      style: TextStyle(
                        fontSize: textScale.scale(13).clamp(11.0, 16.0),
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Location coordinates
          if (latitude != null && longitude != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.map_rounded,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '📍 ${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: textScale.scale(11).clamp(9.0, 14.0),
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          // Get Directions button
          Row(
            children: [
              Icon(
                Icons.directions_rounded,
                size: 14,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Get Directions',
                style: TextStyle(
                  fontSize: textScale.scale(11).clamp(9.0, 14.0),
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
