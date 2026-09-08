// lib/patient/features/medicine_reminders/widgets/reminder_card.dart

import 'package:doctor/patient/features/medicine_reminders/models/medicine_reminder.dart';
import 'package:flutter/material.dart';

class ReminderCard extends StatelessWidget {
  final MedicineReminder reminder;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTakeNow;
  final VoidCallback? onSkipNow;
  final VoidCallback? onTap;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.onTakeNow,
    this.onSkipNow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final adherencePct = reminder.adherencePercentage;
    final isActive = reminder.isActive;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.3),
          ),
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
            // Header: Icon + Name + Toggle
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.medical_services_sharp,
                    size: 24,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
Text(
                          reminder.medicineName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 2),
Row(
                  children: [
                    Expanded(
                      child: Text(
                        reminder.formattedDosage,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        reminder.frequencyLabel,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                    ],
                  ),
                ),
                // Toggle Switch
                // Transform.scale(
                //   scale: 0.8,
                //   child: Switch(
                //     value: isActive,
                //     onChanged: (_) => onToggle(),
                //     activeColor: colorScheme.tertiary,
                //     inactiveThumbColor: colorScheme.onSurfaceVariant,
                //     inactiveTrackColor: colorScheme.surfaceVariant,
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 12),

            // Schedule Details
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withOpacity(0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: colorScheme.secondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      reminder.formattedReminderTimes,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.event_rounded,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                  child: Text(
                    'Started: ${reminder.formattedStartDate}',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Divider
            Divider(
              color: colorScheme.outlineVariant.withOpacity(0.2),
              height: 1,
            ),
            const SizedBox(height: 12),

            // Adherence Breakdown
            Row(
              children: [
                _buildAdherenceItem(
                  context,
                  icon: Icons.check_circle_rounded,
                  label: 'Taken: ${reminder.takenCount}',
                  color: colorScheme.tertiary,
                ),
                const SizedBox(width: 12),
                _buildAdherenceItem(
                  context,
                  icon: Icons.history_toggle_off_rounded,
                  label: 'Skipped: ${reminder.skippedCount}',
                  color: Colors.orange.shade400,
                ),
                const SizedBox(width: 12),
                _buildAdherenceItem(
                  context,
                  icon: Icons.hourglass_top_rounded,
                  label: 'Pending: ${reminder.pendingCount}',
                  color: colorScheme.error,
                ),
                const Spacer(),
                Text(
                  '${adherencePct.toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: reminder.adherenceColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: adherencePct / 100,
                minHeight: 6,
                backgroundColor: colorScheme.surfaceContainer,
                valueColor: AlwaysStoppedAnimation<Color>(
                  reminder.adherenceColor,
                ),
              ),
            ),

            // Intake Actions for Today's Doses
            if (isActive && (onTakeNow != null || onSkipNow != null)) ...[
              const SizedBox(height: 12),
              Divider(
                color: colorScheme.outlineVariant.withOpacity(0.2),
                height: 1,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onSkipNow != null) ...[
                    TextButton.icon(
                      onPressed: onSkipNow,
                      icon: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Colors.orange,
                      ),
                      label: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (onTakeNow != null) ...[
                    ElevatedButton.icon(
                      onPressed: onTakeNow,
                      icon: Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Taken',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdherenceItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
