// lib/features/emergency/screens/sos_detail_screen.dart

import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/doc_top_app_bar.dart';
import 'package:doctor/doctor/features/emergency/controllers/doc_sos_detail_controller.dart';
import 'package:doctor/doctor/features/emergency/models/doc_sos_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DoctorSosDetailScreen extends GetView<DoctorSosDetailController> {
  const DoctorSosDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        if (controller.hasError.value || controller.event.value == null) {
          return _buildErrorState();
        }

        final event = controller.event.value!;
        final isActive = event.isActive;
        return Column(
          children: [
            const TopAppNavBar.gradient(
              title: 'SOS Details',
              height: 64,
              showBackButton: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      // Patient Info Card
                      _buildPatientInfoCard(event, isActive),
                      const SizedBox(height: 16),
                      // Event Info Card
                      _buildEventInfoCard(event, isActive),
                      const SizedBox(height: 16),
                      // Timeline
                      _buildTimeline(event),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom Actions
            if (isActive) _buildBottomActions(event),
          ],
        );
      }),
    );
  }

  Widget _buildLoadingState() {
    return const Column(
      children: [
        TopAppNavBar(title: 'SOS Details', showBackButton: true),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text(
                  'Loading SOS event...',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        const TopAppNavBar(title: 'SOS Details', showBackButton: true),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      size: 36,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Unable to load SOS event',
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.errorMessage.value,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: controller.refreshEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Try Again'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPatientInfoCard(SosEvent event, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? AppColors.error.withOpacity(0.25)
              : AppColors.outlineVariant,
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
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.errorContainer
                      : AppColors.primaryContainer,
                  shape: BoxShape.circle,
                  border: isActive
                      ? Border.all(color: AppColors.error, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    event.patientInitials,
                    style: AppTheme.headlineSmall.copyWith(
                      color: isActive
                          ? AppColors.onErrorContainer
                          : AppColors.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.patientName,
                      style: AppTheme.headlineSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: #PT-${event.patientId.toString().padLeft(4, '0')}',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.error
                      : (event.status == SosStatus.resolved
                            ? Colors.green
                            : AppColors.onSurfaceVariant),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.error.withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.onPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      event.status.displayName.toUpperCase(),
                      style: AppTheme.labelMedium.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.surfaceContainer, height: 1),
          const SizedBox(height: 12),
          // Patient details
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildPatientDetail(
                icon: Icons.phone_rounded,
                label: event.patientPhone ?? 'N/A',
              ),
              _buildPatientDetail(
                icon: Icons.bloodtype_rounded,
                label: event.patientBloodGroup ?? 'N/A',
              ),
              if (event.patientAllergies != null)
                _buildPatientDetail(
                  icon: Icons.warning_rounded,
                  label: event.patientAllergies!,
                  color: AppColors.error,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientDetail({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color ?? AppColors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: color ?? AppColors.onSurface,
            fontWeight: color != null ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildEventInfoCard(SosEvent event, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
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
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.errorContainer
                      : AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emergency_rounded,
                  size: 18,
                  color: isActive
                      ? AppColors.error
                      : AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Event Details',
                style: AppTheme.headlineSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.surfaceContainer, height: 1),
          const SizedBox(height: 12),
          // Triggered at
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Triggered At',
                      style: AppTheme.labelMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      event.dateTimeDisplay,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Location
          if (event.location != null) ...[
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 16,
                  color: isActive
                      ? AppColors.secondary
                      : AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location',
                        style: AppTheme.labelMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        event.location!,
                        style: AppTheme.bodyMedium.copyWith(
                          color: isActive
                              ? AppColors.secondary
                              : AppColors.onSurface,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          // Notes
          if (event.notes != null && event.notes!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
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
                children: [
                  Text(
                    'Patient Notes',
                    style: AppTheme.labelMedium.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.notes!,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppColors.onSurface,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Resolved info
          if (!isActive && event.resolvedAt != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  event.status == SosStatus.resolved
                      ? Icons.check_circle_rounded
                      : Icons.block_rounded,
                  size: 16,
                  color: event.status == SosStatus.resolved
                      ? Colors.green
                      : AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.status == SosStatus.resolved
                            ? 'Resolved At'
                            : 'Marked as False Alarm',
                        style: AppTheme.labelMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        event.resolvedDateTimeDisplay,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeline(SosEvent event) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
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
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.timeline_rounded,
                  size: 18,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Timeline',
                style: AppTheme.headlineSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.surfaceContainer, height: 1),
          const SizedBox(height: 12),
          // Timeline items
          _buildTimelineItem(
            icon: Icons.sos_rounded,
            color: AppColors.error,
            title: '🚨 SOS Triggered',
            time: event.timeDisplay,
          ),
          // _buildTimelineItem(
          //   icon: Icons.campaign_rounded,
          //   color: AppColors.secondary,
          //   title: '📢 Emergency team notified',
          //   time: _getNotifiedTime(event),
          // ),
          if (event.status != SosStatus.active) ...[
            _buildTimelineItem(
              icon: event.status == SosStatus.resolved
                  ? Icons.check_circle_rounded
                  : Icons.block_rounded,
              color: event.status == SosStatus.resolved
                  ? Colors.green
                  : AppColors.onSurfaceVariant,
              title: event.status == SosStatus.resolved
                  ? '✅ SOS Resolved'
                  : '❌ Marked as False Alarm',
              time: event.resolvedTimeDisplay,
              isActive: true,
            ),
          ] else ...[
            // _buildTimelineItem(
            //   icon: Icons.local_hospital_rounded,
            //   color: AppColors.onSurfaceVariant,
            //   title: '🏥 Unit Dispatched',
            //   time: 'Pending',
            //   isPending: true,
            // ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required Color color,
    required String title,
    required String time,
    bool isActive = false,
    bool isPending = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isPending
                  ? AppColors.surfaceVariant
                  : color.withOpacity(0.12),
              shape: BoxShape.circle,
              border: isPending
                  ? Border.all(
                      color: AppColors.outlineVariant,
                      width: 1,
                      style: BorderStyle.solid,
                    )
                  : null,
            ),
            child: Icon(
              icon,
              size: 16,
              color: isPending ? AppColors.onSurfaceVariant : color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyMedium.copyWith(
                    color: isPending
                        ? AppColors.onSurfaceVariant
                        : AppColors.onSurface,
                    fontWeight: isPending ? FontWeight.w400 : FontWeight.w600,
                  ),
                ),
                Text(
                  time,
                  style: AppTheme.bodySmall.copyWith(
                    color: isPending
                        ? AppColors.onSurfaceVariant.withOpacity(0.6)
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getNotifiedTime(SosEvent event) {
    // Notified time is typically 2-3 minutes after trigger
    final notifiedTime = event.createdAt.add(const Duration(minutes: 2));
    final hour = notifiedTime.hour == 0
        ? 12
        : (notifiedTime.hour > 12 ? notifiedTime.hour - 12 : notifiedTime.hour);
    final minute = notifiedTime.minute.toString().padLeft(2, '0');
    final ampm = notifiedTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  Widget _buildBottomActions(SosEvent event) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Primary Action - Resolve
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: controller.isResolving.value
                    ? null
                    : () => _showResolveDialog(event),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  disabledBackgroundColor: Colors.green[700]?.withOpacity(0.4),
                  disabledForegroundColor: AppColors.onPrimary.withOpacity(0.6),
                ),
                child: controller.isResolving.value
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Mark as Resolved',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 8),
            // Secondary Actions
            Row(
              children: [
                // False Alarm
                Expanded(
                  child: TextButton(
                    onPressed: controller.isResolving.value
                        ? null
                        : () => _showFalseAlarmDialog(event),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text(
                      'Mark as False Alarm',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // View Profile
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.toNamed(
                        AppRoutes.docpatientDetail,
                        arguments: {'patientId': event.patientId},
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text(
                      'View Profile',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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

  void _showResolveDialog(SosEvent event) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 24,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Resolve SOS Alert',
                style: AppTheme.headlineSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to mark this SOS alert as resolved?',
              style: AppTheme.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outlineVariant, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Patient: ${event.patientName}',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Triggered: ${event.dateTimeDisplay}',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTheme.labelLarge.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.resolveEvent(status: 'resolved');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }

  void _showFalseAlarmDialog(SosEvent event) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_rounded,
                size: 24,
                color: AppColors.error,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Mark as False Alarm',
                style: AppTheme.headlineSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to mark this SOS alert as a false alarm?',
              style: AppTheme.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outlineVariant, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Patient: ${event.patientName}',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Triggered: ${event.dateTimeDisplay}',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTheme.labelLarge.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.resolveEvent(status: 'false_alarm');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Mark as False Alarm'),
          ),
        ],
      ),
    );
  }
}
