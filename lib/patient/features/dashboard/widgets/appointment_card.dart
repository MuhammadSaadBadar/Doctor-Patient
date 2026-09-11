// lib/patient/features/dashboard/widgets/appointment_card.dart

import 'package:doctor/patient/features/dashboard/models/dashboard_appointment.dart';
import 'package:flutter/material.dart';

class AppointmentCard extends StatelessWidget {
  final DashboardAppointment appointment;
  final VoidCallback onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [
              cs.primary.withOpacity(0.10),
              cs.primaryContainer.withOpacity(0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.primary.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Doctor Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                  colors: [
                    cs.primary.withOpacity(0.18),
                    cs.primary.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.person_rounded, size: 24, color: cs.primary),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.doctorFullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  if (appointment.specialization != null)
                    Text(
                      appointment.specialization!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 11,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _formatDate(appointment.scheduledAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: cs.onSurfaceVariant.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.access_time_rounded,
                        size: 11,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _formatTime(appointment.scheduledAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Status + chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: appointment.isConfirmed
                        ? Colors.green.withOpacity(0.12)
                        : Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    appointment.isConfirmed ? 'Confirmed' : 'Pending',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: appointment.isConfirmed
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $amPm';
  }
}
