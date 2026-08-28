// lib/features/patient/widgets/medicine_reminder_card.dart

import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/features/patient/models/medicine_reminder.dart';
import 'package:flutter/material.dart';

class MedicineReminderCard extends StatelessWidget {
  final MedicineReminder reminder;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggle;

  const MedicineReminderCard({
    super.key,
    required this.reminder,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Fixed Light Mode colors - use AppColors constants directly
    // so the card looks identical in both light and dark mode
    final activeColor = isDark ? AppColors.success : colorScheme.tertiary;
    final activeContainer = isDark
        ? AppColors.successContainer
        : colorScheme.tertiaryContainer;
    final activeOnContainer = isDark
        ? AppColors.onSuccessContainer
        : colorScheme.onTertiaryContainer;

    final dueColor = isDark ? AppColors.primary : colorScheme.primary;
    final dueContainer = isDark
        ? AppColors.primaryContainer
        : colorScheme.primaryContainer;

    final inactiveColor = isDark ? AppColors.outline : colorScheme.outline;
    final inactiveContainer = isDark
        ? AppColors.surfaceContainerHigh
        : colorScheme.surfaceContainerHigh;
    final inactiveOnContainer = isDark
        ? AppColors.onSurfaceVariant
        : colorScheme.onSurfaceVariant;

    final onSurface = isDark ? AppColors.onSurface : colorScheme.onSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : colorScheme.onSurfaceVariant;
    final outlineVariant = isDark
        ? AppColors.outlineVariant
        : colorScheme.outlineVariant;
    final surfaceContainerHigh = isDark
        ? AppColors.surfaceContainerHigh
        : colorScheme.surfaceContainerHigh;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(
        color: reminder.isActive ? null : surfaceContainerHigh,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Icon with status color
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: reminder.isActive
                        ? activeContainer
                        : inactiveContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.medical_services_rounded,
                    color: reminder.isActive ? activeColor : inactiveColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Medicine name and dosage
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.medicineName,
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        reminder.dosage.isNotEmpty
                            ? reminder.dosage
                            : 'No dosage specified',
                        style: AppTheme.bodySmall.copyWith(
                          color: onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: reminder.isActive
                        ? activeContainer
                        : inactiveContainer,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    reminder.statusLabel,
                    style: AppTheme.labelMedium.copyWith(
                      color: reminder.isActive
                          ? activeOnContainer
                          : inactiveOnContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Divider
            Divider(color: outlineVariant, height: 1),
            const SizedBox(height: 12),
            // Details row
            Row(
              children: [
                _buildDetailItem(
                  context,
                  icon: Icons.access_time_rounded,
                  label: 'Times',
                  value: reminder.timesPerDay.toString(),
                ),
                const SizedBox(width: 16),
                _buildDetailItem(
                  context,
                  icon: Icons.schedule_rounded,
                  label: 'Schedule',
                  value: reminder.formattedTimes,
                  flexible: true,
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Date row - responsive layout
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 360;
                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailItem(
                        context,
                        icon: Icons.calendar_today_rounded,
                        label: 'Start',
                        value: _formatDate(reminder.startDate),
                      ),
                      const SizedBox(height: 8),
                      _buildDetailItem(
                        context,
                        icon: reminder.endDate != null
                            ? Icons.calendar_today_rounded
                            : Icons.refresh_rounded,
                        label: 'End',
                        value: reminder.endDate != null
                            ? _formatDate(reminder.endDate!)
                            : 'Ongoing',
                      ),
                      const SizedBox(height: 8),
                      _buildActionButtons(context),
                    ],
                  );
                }
                return Row(
                  children: [
                    _buildDetailItem(
                      context,
                      icon: Icons.calendar_today_rounded,
                      label: 'Start',
                      value: _formatDate(reminder.startDate),
                    ),
                    const SizedBox(width: 16),
                    if (reminder.endDate != null)
                      _buildDetailItem(
                        context,
                        icon: Icons.calendar_today_rounded,
                        label: 'End',
                        value: _formatDate(reminder.endDate!),
                      ),
                    if (reminder.endDate == null)
                      _buildDetailItem(
                        context,
                        icon: Icons.refresh_rounded,
                        label: 'End',
                        value: 'Ongoing',
                      ),
                    const Spacer(),
                    _buildActionButtons(context),
                  ],
                );
              },
            ),
            // Due today indicator
            if (reminder.isDueToday) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: dueContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: dueColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_active_rounded,
                      size: 16,
                      color: dueColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Due today',
                      style: TextStyle(
                        color: dueColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      reminder.formattedTimes,
                      style: TextStyle(
                        color: dueColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool flexible = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : Theme.of(context).colorScheme.onSurfaceVariant;
    final onSurface = isDark
        ? AppColors.onSurface
        : Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTheme.labelMedium.copyWith(
            color: onSurfaceVariant,
            fontSize: 10,
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            value,
            style: AppTheme.bodySmall.copyWith(
              color: onSurface,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = isDark ? AppColors.success : colorScheme.tertiary;
    final warningColor = isDark ? AppColors.warning : colorScheme.secondary;
    final primaryColor = isDark ? AppColors.primaryFixed : colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onToggle != null)
          IconButton(
            onPressed: onToggle,
            icon: Icon(
              reminder.isActive
                  ? Icons.pause_circle_outline
                  : Icons.play_circle_outline,
              color: reminder.isActive ? warningColor : activeColor,
              size: 28,
            ),
            tooltip: reminder.isActive ? 'Deactivate' : 'Activate',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        if (onEdit != null)
          IconButton(
            onPressed: onEdit,
            icon: Icon(Icons.edit_outlined, color: primaryColor),
            tooltip: 'Edit',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        if (onDelete != null)
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
            tooltip: 'Delete',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
