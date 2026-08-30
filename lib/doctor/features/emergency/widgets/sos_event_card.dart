// lib/features/emergency/widgets/sos_event_card.dart

import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/doctor/features/emergency/models/doc_sos_event.dart';
import 'package:flutter/material.dart';

class SosEventCard extends StatelessWidget {
  final SosEvent event;
  final VoidCallback onTap;
  final VoidCallback onResolve;
  final VoidCallback onFalseAlarm;
  final bool isResolving;

  const SosEventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onResolve,
    required this.onFalseAlarm,
    this.isResolving = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isActive = event.isActive;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AppColors.error.withOpacity(0.25)
                : AppColors.outlineVariant.withOpacity(0.5),
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main content with tap gesture
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left border indicator for active events
                      if (isActive)
                        Container(
                          width: 4,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                        ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: isActive ? 12 : 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Row 1: Avatar, Name, Time, Status Badge
                              _buildHeader(isMobile, isActive),
                              const SizedBox(height: 8),
                              // Row 2: Patient ID & Location
                              _buildMetaRow(),
                              const SizedBox(height: 8),
                              // Row 3: Notes
                              _buildNotesSection(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Action buttons (separate from InkWell to prevent navigation on button taps)
            if (isActive) ...[
              const Divider(height: 1, color: AppColors.outlineVariant),
              Padding(
                padding: const EdgeInsets.all(12),
                child: _buildActionButtons(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile, bool isActive) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.errorContainer
                : AppColors.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              event.patientInitials,
              style: AppTheme.titleMedium.copyWith(
                color: isActive
                    ? AppColors.onErrorContainer
                    : AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                fontSize: isMobile ? 13 : 15,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                event.patientName,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontSize: isMobile ? 14 : 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                event.timeAgo,
                style: AppTheme.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: isMobile ? 10 : 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Status Badge
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.error
                  : (event.status == SosStatus.resolved
                        ? Colors.green
                        : AppColors.onSurfaceVariant),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(event.status.icon, size: 12, color: AppColors.onPrimary),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    event.status.displayName.toUpperCase(),
                    style: AppTheme.labelMedium.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetaRow() {
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.badge_rounded,
              size: 14,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              'ID: #PT-${event.patientId.toString().padLeft(4, '0')}',
              style: AppTheme.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_rounded,
              size: 14,
              color: event.isActive
                  ? AppColors.secondary
                  : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              event.location ?? 'Location not available',
              style: AppTheme.bodySmall.copyWith(
                color: event.isActive
                    ? AppColors.secondary
                    : AppColors.onSurfaceVariant,
                fontSize: 12,
                fontWeight: event.isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.outlineVariant.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 12,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                'Triggered: ${event.dateTimeDisplay}',
                style: AppTheme.labelMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            event.notes?.isNotEmpty == true
                ? event.notes!
                : 'No additional notes',
            style: AppTheme.bodySmall.copyWith(
              color: event.notes?.isNotEmpty == true
                  ? AppColors.onSurface
                  : AppColors.onSurfaceVariant,
              fontStyle: event.notes?.isNotEmpty == true
                  ? FontStyle.italic
                  : FontStyle.normal,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Resolve Button
        SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton(
            onPressed: isResolving ? null : onResolve,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: AppTheme.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              disabledBackgroundColor: AppColors.onSurfaceVariant.withOpacity(
                0.4,
              ),
              disabledForegroundColor: AppColors.onSurface.withOpacity(0.6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isResolving)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else ...[
                  const Icon(Icons.check_circle_rounded, size: 18),
                  const SizedBox(width: 8),
                  const Text('Mark as Resolved'),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 40,
          child: OutlinedButton(
            onPressed: isResolving ? null : onFalseAlarm,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: AppTheme.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              disabledForegroundColor: AppColors.onSurfaceVariant.withOpacity(
                0.4,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.block_rounded,
                  size: 18,
                  color: isResolving
                      ? AppColors.onSurfaceVariant.withOpacity(0.4)
                      : AppColors.error,
                ),
                const SizedBox(width: 8),
                const Text('Mark as False Alarm'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
