// lib/patient/features/appointments/widgets/appointment_card.dart

import 'package:doctor/core/widgets/doctor_avatar.dart';
import 'package:doctor/patient/features/appointments/models/appointment.dart';
import 'package:flutter/material.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onTap;
  final VoidCallback? onReschedule;
  final VoidCallback? onCancel;
  final VoidCallback? onPayNow;
  final VoidCallback? onRate;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
    this.onReschedule,
    this.onCancel,
    this.onPayNow,
    this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ✅ Dark: gradient card; Light: solid surface (unchanged)
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
        boxShadow: [
          BoxShadow(
            color: isDark
                ? cs.shadow.withOpacity(0.05)
                : cs.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark
              ? appointment.statusColor.withOpacity(0.35)
              : appointment.statusColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Doctor info + Status chip
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DoctorAvatar(
                imageUrl: appointment.doctor.imageUrl,
                firstName: appointment.doctor.firstName,
                lastName: appointment.doctor.lastName,
                size: 50,
                enableCacheBusting: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.doctorFullName,
                      style: TextStyle(
                        fontSize: textScale.scale(14).clamp(12.0, 15.0),
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appointment.doctorSpecialty,
                      style: TextStyle(
                        fontSize: textScale.scale(11).clamp(9.0, 12.0),
                        // ✅ Dark: bright pink; Light: primary (unchanged)
                        color: isDark ? cs.primaryFixed : cs.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusChip(context),
            ],
          ),

          const SizedBox(height: 14),

          // Appointment details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: appointment.typeIcon == Icons.videocam_rounded
                      ? Colors.purple.withValues(alpha: 0.10)
                      : Colors.blue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  appointment.typeIcon,
                  size: 18,
                  color: appointment.typeIcon == Icons.videocam_rounded
                      ? Colors.purple.shade400
                      : Colors.blue.shade500,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.typeLabel,
                      style: TextStyle(
                        fontSize: textScale.scale(12).clamp(10.0, 13.0),
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${appointment.formattedDate} • ${appointment.timeRange}',
                      style: TextStyle(
                        fontSize: textScale.scale(11).clamp(9.0, 12.0),
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Reason
          if (appointment.reason != null && appointment.reason!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                // ✅ Dark: use surfaceContainerHigh; Light: surfaceContainer (unchanged)
                color: isDark
                    ? cs.surfaceContainerHigh
                    : cs.surfaceContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.note_rounded,
                    size: 14,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment.reason!,
                      style: TextStyle(
                        fontSize: textScale.scale(11).clamp(9.0, 12.0),
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Payment status
          if (appointment.payment != null) ...[
            const SizedBox(height: 12),
            _buildPaymentStatusRow(context),
          ],

          // Action buttons
          const SizedBox(height: 14),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  // ==================== STATUS CHIP ====================

  Widget _buildStatusChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: appointment.statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: appointment.statusColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: appointment.statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            appointment.statusLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: appointment.statusColor,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PAYMENT STATUS ROW ====================

  Widget _buildPaymentStatusRow(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);
    final payment = appointment.payment!;

    final isPaid = payment.isConfirmed;
    final isAwaiting = payment.isAwaitingVerification;
    final isPending = payment.isPending;

    Color getStatusColor() {
      if (isPaid) return Colors.green.shade600;
      if (isAwaiting) return Colors.amber.shade700;
      return Colors.orange.shade600;
    }

    IconData getStatusIcon() {
      if (isPaid) return Icons.check_circle_rounded;
      if (isAwaiting) return Icons.hourglass_top_rounded;
      return Icons.schedule_rounded;
    }

    String getStatusLabel() {
      if (isPaid) return 'Paid';
      if (isAwaiting) return 'Awaiting Verification';
      return 'Unpaid';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: getStatusColor().withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: getStatusColor().withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(getStatusIcon(), size: 15, color: getStatusColor()),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              getStatusLabel(),
              style: TextStyle(
                fontSize: textScale.scale(11).clamp(9.0, 12.0),
                fontWeight: FontWeight.w600,
                color: getStatusColor(),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            payment.formattedTotal,
            style: TextStyle(
              fontSize: textScale.scale(13).clamp(11.0, 14.0),
              fontWeight: FontWeight.w700,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ACTION BUTTONS ====================

  Widget _buildActionButtons(BuildContext context) {
    final buttons = <Widget>[];

    buttons.add(
      _buildActionButton(
        context,
        label: 'View',
        icon: Icons.visibility_rounded,
        isPrimary: true,
        onTap: onTap,
      ),
    );

    if (onReschedule != null &&
        (appointment.isPending || appointment.isConfirmed)) {
      buttons.add(
        _buildActionButton(
          context,
          label: 'Reschedule',
          icon: Icons.schedule_rounded,
          onTap: onReschedule,
        ),
      );
    }

    if (onCancel != null &&
        (appointment.isPending || appointment.isConfirmed)) {
      buttons.add(
        _buildActionButton(
          context,
          label: 'Cancel',
          icon: Icons.cancel_rounded,
          isDanger: true,
          onTap: onCancel,
        ),
      );
    }

    if (onPayNow != null &&
        appointment.payment != null &&
        appointment.payment!.isPending) {
      buttons.add(
        _buildActionButton(
          context,
          label: 'Pay Now',
          icon: Icons.payment_rounded,
          isPayment: true,
          onTap: onPayNow,
        ),
      );
    }

    if (onRate != null &&
        appointment.isCompleted &&
        appointment.payment?.isConfirmed == true) {
      buttons.add(
        _buildActionButton(
          context,
          label: 'Rate',
          icon: Icons.star_rounded,
          isRating: true,
          onTap: onRate,
        ),
      );
    }

    return Wrap(spacing: 8, runSpacing: 8, children: buttons);
  }

  // ==================== ACTION BUTTON BUILDER ====================

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    VoidCallback? onTap,
    bool isPrimary = false,
    bool isDanger = false,
    bool isPayment = false,
    bool isRating = false,
  }) {
    final cs = Theme.of(context).colorScheme;

    Color getBackgroundColor() {
      if (isPrimary) return cs.primary;
      if (isDanger) return cs.error;
      if (isPayment) return Colors.amber.shade700;
      if (isRating) return Colors.amber.shade700;
      return Colors.transparent;
    }

    Color getForegroundColor() {
      if (isPrimary) return cs.onPrimary;
      if (isDanger) return cs.onError;
      if (isPayment) return Colors.white;
      if (isRating) return Colors.white;
      return cs.primary;
    }

    final bool isFilled = isPrimary || isDanger || isPayment || isRating;

    if (isFilled) {
      return ElevatedButton.icon(
        icon: Icon(icon, size: 15),
        label: Text(label),
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: getBackgroundColor(),
          foregroundColor: getForegroundColor(),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          elevation: isPrimary ? 1 : 0,
        ),
      );
    }

    return OutlinedButton.icon(
      icon: Icon(icon, size: 15),
      label: Text(label),
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: cs.primary,
        side: BorderSide(color: cs.primary, width: 1),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
