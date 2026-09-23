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

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _semanticFg(BuildContext context, Color base) {
    final isDark = _isDark(context);
    if (base == Colors.green)
      return isDark ? Colors.green.shade300 : Colors.green.shade800;
    if (base == Colors.orange)
      return isDark ? Colors.orange.shade300 : Colors.orange.shade800;
    if (base == Colors.red)
      return isDark ? Colors.red.shade300 : Colors.red.shade800;
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);
    final adherencePct = reminder.adherencePercentage;
    final isActive = reminder.isActive;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // ✅ Gradient in dark, solid in light
          gradient: isDark
              ? LinearGradient(
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                  colors: [
                    cs.primary.withOpacity(0.10),
                    cs.primaryContainer.withOpacity(0.06),
                  ],
                )
              : null,
          color: !isDark ? cs.surfaceContainerLowest : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? cs.primary.withOpacity(0.12)
                : cs.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: cs.shadow.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(isDark ? 0.18 : 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.medical_services_sharp,
                    size: 24,
                    color: cs.primary,
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
                          color: cs.onSurface,
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
                                color: cs.onSurface,
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
                              color: cs.outlineVariant,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              reminder.frequencyLabel,
                              style: TextStyle(
                                fontSize: 13,
                                color: cs.onSurfaceVariant,
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
              ],
            ),
            const SizedBox(height: 12),

            // Schedule Details
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                // ✅ Dark: slightly lifted inner box
                color: isDark
                    ? cs.primaryContainer.withOpacity(0.08)
                    : cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? cs.primary.withOpacity(0.10)
                      : cs.outlineVariant.withOpacity(0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 16, color: cs.secondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      reminder.formattedReminderTimes,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.event_rounded,
                    size: 14,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Started: ${reminder.formattedStartDate}',
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Divider(
              color: isDark
                  ? cs.primary.withOpacity(0.12)
                  : cs.outlineVariant.withOpacity(0.2),
              height: 1,
            ),
            const SizedBox(height: 12),

            // Adherence Breakdown — semantic foreground colors
            Row(
              children: [
                _buildAdherenceItem(
                  context,
                  icon: Icons.check_circle_rounded,
                  label: 'Taken: ${reminder.takenCount}',
                  color: cs.tertiary,
                ),
                const SizedBox(width: 12),
                _buildAdherenceItem(
                  context,
                  icon: Icons.history_toggle_off_rounded,
                  label: 'Skipped: ${reminder.skippedCount}',
                  color: _semanticFg(context, Colors.orange),
                ),
                const SizedBox(width: 12),
                _buildAdherenceItem(
                  context,
                  icon: Icons.hourglass_top_rounded,
                  label: 'Pending: ${reminder.pendingCount}',
                  color: cs.error,
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

            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: adherencePct / 100,
                minHeight: 6,
                backgroundColor: isDark
                    ? cs.primary.withOpacity(0.12)
                    : cs.surfaceContainer,
                valueColor: AlwaysStoppedAnimation<Color>(
                  reminder.adherenceColor,
                ),
              ),
            ),

            // Intake actions — semantic colors
            if (isActive && (onTakeNow != null || onSkipNow != null)) ...[
              const SizedBox(height: 12),
              Divider(
                color: isDark
                    ? cs.primary.withOpacity(0.12)
                    : cs.outlineVariant.withOpacity(0.2),
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
                        color: _semanticFg(context, Colors.orange),
                      ),
                      label: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _semanticFg(context, Colors.orange),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: _semanticFg(context, Colors.orange),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: _semanticFg(
                              context,
                              Colors.orange,
                            ).withOpacity(isDark ? 0.5 : 0.3),
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
                        color: cs.onTertiary,
                      ),
                      label: Text(
                        'Taken',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: cs.onTertiary,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        // ✅ Use tertiary token instead of raw green
                        backgroundColor: cs.tertiary,
                        foregroundColor: cs.onTertiary,
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
