// lib/patient/features/medicine_reminders/screens/medicine_reminder_detail_screen.dart

import 'package:doctor/patient/features/medicine_reminders/controllers/intake_log_controller.dart';
import 'package:doctor/patient/features/medicine_reminders/controllers/medicine_reminder_detail_controller.dart';
import 'package:doctor/patient/features/medicine_reminders/models/medicine_reminder.dart';
import 'package:doctor/patient/features/medicine_reminders/widgets/reminder_card.dart';
import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MedicineReminderDetailScreen
    extends GetView<MedicineReminderDetailController> {
  const MedicineReminderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: PatientTopAppBar(
        title: 'Reminder Details',
        titleBuilder: (_) => Obx(
          () => Text(
            controller.reminder.value?.medicineName ?? 'Reminder Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              fontFamily: 'PlayfairDisplay',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailingActions: [
          Obx(() {
            if (controller.reminder.value == null) {
              return const SizedBox.shrink();
            }
            return PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: colorScheme.onSurface),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    controller.navigateToEdit();
                    break;
                  case 'delete':
                    controller.deleteReminder();
                    break;
                  case 'logs':
                    controller.navigateToIntakeLogs();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_rounded,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text('Edit Reminder'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'logs',
                  child: Row(
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 18,
                        color: colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      const Text('View Intake Logs'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete_rounded,
                        size: 18,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 8),
                      const Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState(context);
        }

        if (controller.hasError.value) {
          return _buildErrorState(context);
        }

        final reminder = controller.reminder.value;
        if (reminder == null) {
          return _buildErrorState(context);
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadReminder(reminder.id),
          color: colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reminder Card with Toggle
                ReminderCard(
                  reminder: reminder,
                  onToggle: controller.toggleReminder,
                  onEdit: controller.navigateToEdit,
                  onDelete: controller.deleteReminder,
                  onTakeNow: () {
                    if (Get.isRegistered<IntakeLogController>()) {
                      final intakeController = Get.find<IntakeLogController>();
                      intakeController.logIntake(
                        reminderId: reminder.id,
                        status: 'taken',
                        scheduledFor: DateTime.now(),
                      );
                    }
                  },
                  onSkipNow: () {
                    if (Get.isRegistered<IntakeLogController>()) {
                      final intakeController = Get.find<IntakeLogController>();
                      intakeController.logIntake(
                        reminderId: reminder.id,
                        status: 'skipped',
                        scheduledFor: DateTime.now(),
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Details Section
                _buildDetailsSection(context, reminder),
                const SizedBox(height: 24),

                _buildIntakeActions(context, reminder),
                const SizedBox(height: 24),

                // Action Buttons
                _buildActionButtons(context),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDetailsSection(BuildContext context, MedicineReminder reminder) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              fontFamily: 'PlayfairDisplay',
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            icon: Icons.medication_rounded,
            label: 'Medicine',
            value: reminder.medicineName,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            context,
            icon: Icons.medication_rounded,
            label: 'Dosage',
            value: reminder.dosage.isNotEmpty
                ? reminder.dosage
                : 'Not specified',
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            context,
            icon: Icons.repeat_rounded,
            label: 'Frequency',
            value: reminder.frequencyLabel,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            context,
            icon: Icons.schedule_rounded,
            label: 'Reminder Times',
            value: reminder.formattedReminderTimes,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            context,
            icon: Icons.calendar_today_rounded,
            label: 'Start Date',
            value: reminder.formattedStartDate,
          ),
          if (reminder.endDate != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              icon: Icons.event_busy_rounded,
              label: 'End Date',
              value: _formatDate(reminder.endDate!),
            ),
          ],
          const SizedBox(height: 12),
          _buildDetailRow(
            context,
            icon: Icons.toggle_on_rounded,
            label: 'Status',
            value: reminder.isActive ? 'Active' : 'Inactive',
            valueColor: reminder.isActive
                ? colorScheme.tertiary
                : colorScheme.error,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            context,
            icon: Icons.access_time_rounded,
            label: 'Created',
            value: _formatDateTime(reminder.createdAt),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            context,
            icon: Icons.update_rounded,
            label: 'Last Updated',
            value: _formatDateTime(reminder.updatedAt),
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
    Color? valueColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: controller.navigateToIntakeLogs,
            icon: Icon(
              Icons.history_rounded,
              size: 18,
              color: colorScheme.primary,
            ),
            label: Text(
              'Intake History',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntakeActions(BuildContext context, MedicineReminder reminder) {
    final colorScheme = Theme.of(context).colorScheme;
    final intakeController = Get.find<IntakeLogController>();

    if (!reminder.isActive) return const SizedBox.shrink();

    Future<void> logIntake(String status) async {
      await intakeController.logIntake(
        reminderId: reminder.id,
        status: status,
        scheduledFor: DateTime.now(),
      );
    }

    return Obx(() {
      final isLogging = intakeController.isLoggingIntake.value;
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isLogging ? null : () => logIntake('skipped'),
              icon: const Icon(Icons.close_rounded),
              label: const Text('Skip'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange.shade700,
                side: BorderSide(color: Colors.orange.shade700),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isLogging ? null : () => logIntake('taken'),
              icon: const Icon(Icons.check_rounded),
              label: const Text('Taken'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.tertiary,
                foregroundColor: colorScheme.onTertiary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading details...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final args = Get.arguments;
                if (args != null && args['reminderId'] != null) {
                  controller.loadReminder(args['reminderId']);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDateTime(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    return '${months[date.month - 1]} ${date.day}, ${date.year} at $hour:$minute $amPm';
  }
}
