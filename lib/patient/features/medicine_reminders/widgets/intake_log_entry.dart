// lib/patient/features/medicine_reminders/widgets/intake_log_entry.dart

import 'package:doctor/patient/features/medicine_reminders/models/medicine_intake_log.dart';
import 'package:flutter/material.dart';

class IntakeLogEntry extends StatelessWidget {
  final MedicineIntakeLog log;
  final String medicineName;
  final VoidCallback? onTakeNow;
  final VoidCallback? onSkipNow;

  const IntakeLogEntry({
    super.key,
    required this.log,
    required this.medicineName,
    this.onTakeNow,
    this.onSkipNow,
  });

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _semanticFg(BuildContext context, Color base) {
    final isDark = _isDark(context);
    if (base == Colors.green)
      return isDark ? Colors.green.shade300 : Colors.green.shade800;
    if (base == Colors.orange)
      return isDark ? Colors.orange.shade300 : Colors.orange.shade800;
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    // ✅ Semantic colors used for status badges & action buttons
    final takenFg = _semanticFg(context, Colors.green);
    final skipFg = _semanticFg(context, Colors.orange);
    final statusFg = log.statusColor == Colors.green
        ? takenFg
        : (log.statusColor == Colors.orange ? skipFg : log.statusColor);

    return Container(
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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusFg.withOpacity(isDark ? 0.22 : 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.medication_rounded, size: 20, color: statusFg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicineName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${log.statusLabel} • ${formatTime(log.scheduledFor)}',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusFg.withOpacity(isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(log.statusIcon, size: 12, color: statusFg),
                    const SizedBox(width: 4),
                    Text(
                      log.statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusFg,
                      ),
                    ),
                  ],
                ),
              ),
              if (log.isTaken && log.takenAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Taken at ${formatTime(log.takenAt!)}',
                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                ),
              ],
              if (log.isPending &&
                  (onTakeNow != null || onSkipNow != null)) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onTakeNow != null) ...[
                      GestureDetector(
                        onTap: onTakeNow,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            // ✅ Use tertiary for "taken"
                            color: cs.tertiary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Taken',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: cs.onTertiary,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (onTakeNow != null && onSkipNow != null) ...[
                      const SizedBox(width: 8),
                    ],
                    if (onSkipNow != null) ...[
                      GestureDetector(
                        onTap: onSkipNow,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            // ✅ Semantic orange for skip, brightness-aware
                            color: skipFg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              // ✅ Dark text on light orange in dark; white on dark orange in light
                              color: isDark
                                  ? Colors.black.withOpacity(0.75)
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              if (log.isSkipped) ...[
                const SizedBox(height: 4),
                Text(
                  'Skipped',
                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String formatTime(DateTime time) {
    final hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final amPm = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $amPm';
  }
}
