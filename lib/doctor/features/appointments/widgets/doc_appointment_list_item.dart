import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/doctor/features/appointments/models/doc_appointment_schedule.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppointmentListItem extends StatelessWidget {
  final AppointmentSchedule appointment;
  final VoidCallback onViewNotes;

  const AppointmentListItem({
    super.key,
    required this.appointment,
    required this.onViewNotes,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Get.toNamed(
          AppRoutes.docappointmentDetail,
          arguments: appointment.id.toString(),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.outlineSubtle, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Left accent strip
                  Container(width: 4, color: appointment.statusColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: isDesktop
                          ? _buildDesktopLayout()
                          : _buildMobileLayout(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _buildAvatar(radius: 22),
        const SizedBox(width: 14),
        _buildInfo(),
        const SizedBox(width: 14),
        Flexible(child: _buildStatusAndAction()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildAvatar(radius: 20),
            const SizedBox(width: 10),
            _buildInfo(),
          ],
        ),
        const SizedBox(height: 10),
        Container(height: 1, color: AppColors.outlineSubtle),
        const SizedBox(height: 10),
        _buildStatusAndAction(),
      ],
    );
  }

  Widget _buildAvatar({required double radius}) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          appointment.patientInitials,
          style: AppTheme.titleMedium.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w700,
            fontSize: radius * 0.70,
          ),
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appointment.patientName,
            style: AppTheme.titleMedium.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Icon(
                Icons.event_rounded,
                size: 12,
                color: AppColors.primaryMuted,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(appointment.date),
                style: AppTheme.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                appointment.typeDisplay,
                style: AppTheme.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            'Dr. ${appointment.doctorName}',
            style: AppTheme.bodySmall.copyWith(
              color: AppColors.primaryMuted,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          if (appointment.payment != null) ...[
            const SizedBox(height: 6),
            _PaymentBadge(status: appointment.payment!.status),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusAndAction() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: appointment.statusColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: appointment.statusColor.withOpacity(0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                appointment.status == AppointmentStatus.completed
                    ? Icons.check_circle_rounded
                    : Icons.schedule_rounded,
                size: 12,
                color: appointment.statusColor,
              ),
              const SizedBox(width: 4),
              Text(
                appointment.statusDisplay,
                style: AppTheme.labelSmall.copyWith(
                  color: appointment.statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onViewNotes,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            // mainAxisSize: MainAxisSize.min,
            // children: [
            //   Text(
            //     'View Notes',
            //     style: AppTheme.labelLarge.copyWith(
            //       color: AppColors.secondary,
            //       fontWeight: FontWeight.w600,
            //     ),
            //   ),
            //   const SizedBox(width: 2),
            //   Icon(
            //     Icons.arrow_forward_ios_rounded,
            //     size: 11,
            //     color: AppColors.secondary,
            //   ),
            // ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
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
}

// ── Payment badge ──────────────────────────────────────────────────────────────

class _PaymentBadge extends StatelessWidget {
  final AppointmentPaymentStatus status;
  const _PaymentBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color textColor;
    final String label;

    switch (status) {
      case AppointmentPaymentStatus.confirmed:
        bg = AppColors.successContainer;
        textColor = AppColors.onSuccessContainer;
        label = 'Paid';
        break;
      case AppointmentPaymentStatus.awaitingVerification:
        bg = AppColors.warningContainer;
        textColor = AppColors.onWarningContainer;
        label = 'Awaiting Verification';
        break;
      case AppointmentPaymentStatus.pending:
        bg = AppColors.primarySubtle;
        textColor = AppColors.primaryMuted;
        label = 'Payment Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTheme.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
