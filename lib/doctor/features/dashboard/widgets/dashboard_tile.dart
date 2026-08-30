import 'package:flutter/material.dart';
import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';
import 'package:doctor/doctor/features/dashboard/models/doc_dashboard_appointment.dart';

class AppointmentTile extends StatelessWidget {
  final DashboardAppointment appointment;
  final VoidCallback onTap;

  const AppointmentTile({
    super.key,
    required this.appointment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: appointment.isUpNext
                    ? AppColors.primaryContainer
                    : AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  appointment.initials,
                  style: AppTheme.headlineSmall.copyWith(
                    fontSize: 18,
                    color: appointment.isUpNext
                        ? AppColors.onPrimary
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Name and type
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.name,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      MaterialSymbolIcon(
                        appointment.icon,
                        size: 16,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        appointment.type,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Time and status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  appointment.time,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
                if (appointment.isUpNext)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tertiary,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      'Up Next',
                      style: AppTheme.labelMedium.copyWith(
                        color: AppColors.onTertiary,
                        fontSize: 10,
                      ),
                    ),
                  )
                else if (appointment.duration != null)
                  Text(
                    appointment.duration!,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
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
