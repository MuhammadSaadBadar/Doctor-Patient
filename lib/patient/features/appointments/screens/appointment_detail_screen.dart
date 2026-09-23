// lib/patient/features/appointments/screens/appointment_detail_screen.dart

import 'package:doctor/core/localization/translation_keys.dart';
import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/core/widgets/doctor_avatar.dart';
import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:doctor/patient/features/appointments/controllers/appointment_detail_controller.dart';
import 'package:doctor/patient/features/appointments/models/appointment.dart';
import 'package:doctor/patient/features/doctors/widgets/doctor_address_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppointmentDetailScreen extends GetView<AppointmentDetailController> {
  const AppointmentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // ✅ surface instead of deprecated background
      backgroundColor: colorScheme.background,
      appBar: PatientTopAppBar(title: TranslationKeys.bookingDetails.tr),
      body: Obx(() {
        if (controller.isLoading.value) return _buildLoadingState(context);
        if (controller.hasError.value) return _buildErrorState(context);

        final appointment = controller.appointment.value;
        if (appointment == null) return _buildEmptyState(context);

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusBadge(context, appointment),
                const SizedBox(height: 24),
                _buildDoctorSection(context, appointment),
                const SizedBox(height: 24),
                _buildDetailsSection(context, appointment),
                const SizedBox(height: 24),
                if (appointment.payment != null) ...[
                  _buildPaymentSection(context, appointment),
                  const SizedBox(height: 24),
                ],
                if (controller.showDoctorContact &&
                    controller.hasDoctorContact) ...[
                  _buildDoctorContactSection(context),
                  const SizedBox(height: 24),
                ],
                if (appointment.doctorNotes != null &&
                    appointment.doctorNotes!.isNotEmpty) ...[
                  _buildDoctorNotesSection(context, appointment),
                  const SizedBox(height: 24),
                ],
                if (appointment.isCancelled &&
                    appointment.cancellationReason != null &&
                    appointment.cancellationReason!.isNotEmpty) ...[
                  _buildCancellationSection(context, appointment),
                  const SizedBox(height: 24),
                ],
                _buildActionButtons(context, appointment),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Shared helpers
  // ─────────────────────────────────────────────────────────────

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// A card decoration that works in both light and dark:
  /// - Light: soft shadow + white surface
  /// - Dark:  no shadow + slightly lifted surface + subtle outline
  BoxDecoration _cardDecoration(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      // ✅ Dark: gradient over the scaffold (matches SettingsSection / profile cards)
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
      // ✅ Light: solid surface
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
    );
  }

  /// Returns a foreground color for a semantic hue that
  /// stays readable on both light and dark backgrounds.
  Color _semanticFg(BuildContext context, Color base) {
    final isDark = _isDark(context);
    // In dark mode, use the "shade200/300" equivalents of the hue.
    if (base == Colors.green)
      return isDark ? Colors.green.shade300 : Colors.green.shade800;
    if (base == Colors.red)
      return isDark ? Colors.red.shade300 : Colors.red.shade800;
    if (base == Colors.amber)
      return isDark ? Colors.amber.shade300 : Colors.amber.shade800;
    if (base == Colors.orange)
      return isDark ? Colors.orange.shade300 : Colors.orange.shade800;
    return base;
  }

  Color _semanticBg(BuildContext context, Color base) {
    final isDark = _isDark(context);
    return base.withValues(alpha: isDark ? 0.18 : 0.08);
  }

  Color _semanticBorder(BuildContext context, Color base) {
    final isDark = _isDark(context);
    return base.withValues(alpha: isDark ? 0.45 : 0.30);
  }

  // ─────────────────────────────────────────────────────────────
  // Status badge
  // ─────────────────────────────────────────────────────────────

  Widget _buildStatusBadge(BuildContext context, Appointment appointment) {
    final textScale = MediaQuery.textScalerOf(context);
    final statusColor = appointment.statusColor;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _semanticBg(context, statusColor),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: _semanticBorder(context, statusColor),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _semanticFg(context, statusColor),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              appointment.statusLabel,
              style: TextStyle(
                fontSize: textScale.scale(14).clamp(12.0, 16.0),
                fontWeight: FontWeight.w700,
                color: _semanticFg(context, statusColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Doctor section
  // ─────────────────────────────────────────────────────────────

  Widget _buildDoctorSection(BuildContext context, Appointment appointment) {
    final cs = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DoctorAvatar(
            imageUrl: appointment.doctor.imageUrl,
            firstName: appointment.doctor.firstName,
            lastName: appointment.doctor.lastName,
            size: 64,
            enableCacheBusting: true,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  appointment.doctorFullName,
                  style: TextStyle(
                    fontSize: textScale.scale(16).clamp(14.0, 18.0),
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.doctorSpecialty,
                  style: TextStyle(
                    fontSize: textScale.scale(12).clamp(10.0, 14.0),
                    color: cs.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      appointment.typeIcon,
                      size: 16,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        appointment.typeLabel,
                        style: TextStyle(
                          fontSize: textScale.scale(11).clamp(9.0, 13.0),
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
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Details section
  // ─────────────────────────────────────────────────────────────

  Widget _buildDetailsSection(BuildContext context, Appointment appointment) {
    final cs = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            TranslationKeys.bookingDetails.tr,
            style: TextStyle(
              fontSize: textScale.scale(14).clamp(12.0, 16.0),
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            Icons.calendar_today_rounded,
            TranslationKeys.appointmentsDate.tr,
            appointment.formattedDate,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            context,
            Icons.access_time_rounded,
            TranslationKeys.appointmentsTime.tr,
            appointment.timeRange,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            context,
            Icons.timer_rounded,
            TranslationKeys.appointmentsDuration.tr,
            appointment.formattedDuration,
          ),
          if (appointment.appointmentType == 'in_person') ...[
            const SizedBox(height: 12),
            Obx(
              () => DoctorAddressCard(
                area: controller.doctorProfile.value?.area,
                city: controller.doctorProfile.value?.city,
                latitude: controller.doctorProfile.value?.latitude,
                longitude: controller.doctorProfile.value?.longitude,
              ),
            ),
          ],
          if (appointment.appointmentType == 'video_consultation' &&
              appointment.meetingLink != null &&
              appointment.meetingLink!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              Icons.video_call_rounded,
              TranslationKeys.appointmentsMeetingLink.tr,
              TranslationKeys.appointmentsTapToJoin.tr,
            ),
          ],
          if (appointment.reason != null && appointment.reason!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              Icons.note_rounded,
              TranslationKeys.appointmentsReason.tr,
              appointment.reason!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final cs = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);
    final isDark = _isDark(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark
                ? cs.primaryContainer.withValues(alpha: 0.25)
                : cs.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: cs.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: textScale.scale(11).clamp(9.0, 12.0),
                  fontWeight: FontWeight.w500,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: textScale.scale(12).clamp(10.0, 14.0),
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Payment section
  // ─────────────────────────────────────────────────────────────

  Widget _buildPaymentSection(BuildContext context, Appointment appointment) {
    final cs = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);
    final payment = appointment.payment!;
    final statusColor = controller.paymentStatusColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context).copyWith(
        border: Border.all(
          color: _semanticBorder(context, statusColor),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                TranslationKeys.appointmentsPayment.tr,
                style: TextStyle(
                  fontSize: textScale.scale(14).clamp(12.0, 16.0),
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _semanticBg(context, statusColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  controller.paymentStatusLabel,
                  style: TextStyle(
                    fontSize: textScale.scale(11).clamp(9.0, 12.0),
                    fontWeight: FontWeight.w600,
                    color: _semanticFg(context, statusColor),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPaymentRow(
            context,
            TranslationKeys.appointmentsConsultationFee.tr,
            payment.formattedDoctorFee,
          ),
          const SizedBox(height: 8),
          _buildPaymentRow(
            context,
            TranslationKeys.appointmentsPlatformFee.tr,
            payment.formattedCommission,
          ),
          Divider(height: 24, color: cs.outlineVariant),
          _buildPaymentRow(
            context,
            TranslationKeys.appointmentsTotalAmount.tr,
            payment.formattedTotal,
            isTotal: true,
          ),
          const SizedBox(height: 12),
          Text(
            controller.paymentStatusDisplay,
            style: TextStyle(
              fontSize: textScale.scale(12).clamp(10.0, 13.0),
              color: cs.onSurfaceVariant,
            ),
          ),
          if (payment.paymentReference.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              TranslationKeys.appointmentsReference.tr.replaceAll(
                '@reference',
                payment.paymentReference,
              ),
              style: TextStyle(
                fontSize: textScale.scale(11).clamp(9.0, 12.0),
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: textScale
                  .scale(isTotal ? 14 : 12)
                  .clamp(10.0, isTotal ? 16.0 : 14.0),
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? cs.onSurface : cs.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: textScale
                .scale(isTotal ? 16 : 12)
                .clamp(10.0, isTotal ? 18.0 : 14.0),
            fontWeight: FontWeight.w700,
            color: isTotal ? cs.primary : cs.onSurface,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Doctor contact (green semantic)
  // ─────────────────────────────────────────────────────────────

  Widget _buildDoctorContactSection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _semanticBg(context, Colors.green),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _semanticBorder(context, Colors.green),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.contact_phone_rounded,
                color: _semanticFg(context, Colors.green),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                TranslationKeys.appointmentsDoctorContact.tr,
                style: TextStyle(
                  fontSize: textScale.scale(14).clamp(12.0, 16.0),
                  fontWeight: FontWeight.w700,
                  color: _semanticFg(context, Colors.green),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            controller.doctorPhone,
            style: TextStyle(
              fontSize: textScale.scale(14).clamp(12.0, 16.0),
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Doctor notes
  // ─────────────────────────────────────────────────────────────

  Widget _buildDoctorNotesSection(
    BuildContext context,
    Appointment appointment,
  ) {
    final cs = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_information_rounded,
                color: cs.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                TranslationKeys.appointmentsDoctorNotes.tr,
                style: TextStyle(
                  fontSize: textScale.scale(14).clamp(12.0, 16.0),
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            appointment.doctorNotes!,
            style: TextStyle(
              fontSize: textScale.scale(12).clamp(10.0, 14.0),
              height: 1.6,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Cancellation (red semantic)
  // ─────────────────────────────────────────────────────────────

  Widget _buildCancellationSection(
    BuildContext context,
    Appointment appointment,
  ) {
    final cs = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _semanticBg(context, Colors.red),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _semanticBorder(context, Colors.red),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.cancel_rounded,
                color: _semanticFg(context, Colors.red),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                TranslationKeys.appointmentsCancellationReason.tr,
                style: TextStyle(
                  fontSize: textScale.scale(14).clamp(12.0, 16.0),
                  fontWeight: FontWeight.w700,
                  color: _semanticFg(context, Colors.red),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            appointment.cancellationReason!,
            style: TextStyle(
              fontSize: textScale.scale(12).clamp(10.0, 14.0),
              height: 1.6,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Action buttons — use error / primary / tertiary instead of raw Colors
  // ─────────────────────────────────────────────────────────────

  Widget _buildActionButtons(BuildContext context, Appointment appointment) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttons = <Widget>[];

    if (controller.canCancel) {
      buttons.add(
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.cancel_rounded, size: 18),
            label: const Text(
              'Cancel',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              // ✅ Dark: brighter red for contrast; Light: use error token
              foregroundColor: isDark ? const Color(0xFFE57373) : cs.error,
              side: BorderSide(
                color: isDark ? const Color(0xFFE57373) : cs.error,
                width: 1.5,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () => _showCancelDialog(context, appointment),
          ),
        ),
      );
    }

    if (controller.canReschedule) {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 12));
      buttons.add(
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.schedule_rounded, size: 18),
            label: const Text(
              'Reschedule',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.primary,
              side: BorderSide(color: cs.primary, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () => _navigateToReschedule(appointment),
          ),
        ),
      );
    }

    if (controller.canPayNow) {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 12));
      buttons.add(
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.payment_rounded, size: 18),
            label: const Text(
              'Pay Now',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.tertiaryContainer,
              foregroundColor: cs.onTertiaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () => _markPaymentAsPaid(appointment),
          ),
        ),
      );
    }

    if (controller.canRate) {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 12));
      buttons.add(
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.star_rounded, size: 18),
            label: const Text(
              'Rate',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.tertiary,
              side: BorderSide(color: cs.tertiary, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () => _showRatingDialog(context, appointment),
          ),
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    // ✅ Row (not Wrap) so Expanded children actually flex
    return Row(children: buttons);
  }
  // ─────────────────────────────────────────────────────────────
  // Loading / Error / Empty
  // ─────────────────────────────────────────────────────────────

  Widget _buildLoadingState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: isDark ? 0.35 : 0.2),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(color: cs.primary, strokeWidth: 3),
          ),
          const SizedBox(height: 16),
          Text(
            TranslationKeys.appointmentsLoadingDetail.tr,
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: cs.onErrorContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: textScale.scale(16).clamp(14.0, 18.0),
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: textScale.scale(12).clamp(10.0, 14.0),
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(TranslationKeys.commonTryAgain.tr),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 64,
              color: cs.outline.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Appointment Not Found',
              style: TextStyle(
                fontSize: textScale.scale(16).clamp(14.0, 18.0),
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The appointment you\'re looking for could not be found.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: textScale.scale(12).clamp(10.0, 14.0),
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(TranslationKeys.appointmentsBackToAppointments.tr),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Dialogs
  // ─────────────────────────────────────────────────────────────

  void _showCancelDialog(BuildContext context, Appointment appointment) {
    final cs = Theme.of(context).colorScheme;
    final reasonController = TextEditingController();

    Get.defaultDialog(
      title: TranslationKeys.appointmentsCancelTitle.tr,
      titleStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: cs.onSurface,
      ),
      backgroundColor: cs.surfaceContainerHigh,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Are you sure you want to cancel your appointment with ${appointment.doctorFullName} on ${appointment.formattedDate} at ${appointment.formattedTime}?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: reasonController,
            decoration: InputDecoration(
              labelText: 'Reason (optional)',
              hintText: TranslationKeys.appointmentsCancelHint.tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            maxLines: 3,
          ),
        ],
      ),
      textCancel: 'Keep Appointment',
      textConfirm: 'Cancel Appointment',
      // ✅ Let GetX theme the confirm button — no hardcoded white
      buttonColor: cs.error,
      confirmTextColor: cs.onError,
      cancelTextColor: cs.onSurface,
      onConfirm: () async {
        Get.back();
        final reason = reasonController.text.trim();
        await controller.cancelAppointment(reason.isEmpty ? null : reason);
      },
    );
  }

  void _navigateToReschedule(Appointment appointment) {
    Get.toNamed(
      AppRoutes.rescheduleAppointment,
      arguments: {'appointmentId': appointment.id},
    );
  }

  void _markPaymentAsPaid(Appointment appointment) async {
    await controller.markPaymentAsPaid();
  }

  void _showRatingDialog(BuildContext context, Appointment appointment) {
    final cs = Theme.of(context).colorScheme;
    int selectedScore = 5;
    final commentController = TextEditingController();

    Get.defaultDialog(
      title: TranslationKeys.appointmentsRateTitle.tr,
      titleStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: cs.onSurface,
      ),
      backgroundColor: cs.surfaceContainerHigh,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'How was your appointment with ${appointment.doctorFullName}?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          StatefulBuilder(
            builder: (context, setState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final star = index + 1;
                  return GestureDetector(
                    onTap: () => setState(() => selectedScore = star),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        star <= selectedScore
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 36,
                        // ✅ Use theme tertiary for stars
                        color: star <= selectedScore
                            ? cs.tertiary
                            : cs.onSurfaceVariant,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: commentController,
            decoration: InputDecoration(
              labelText: 'Comment (optional)',
              hintText: TranslationKeys.appointmentsRateHint.tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            maxLines: 3,
          ),
        ],
      ),
      textCancel: 'Cancel',
      textConfirm: 'Submit Rating',
      // ✅ Theme-aware confirm button
      buttonColor: cs.primary,
      confirmTextColor: cs.onPrimary,
      cancelTextColor: cs.onSurface,
      onConfirm: () async {
        Get.back();
        final comment = commentController.text.trim();
        await controller.rateAppointment(
          selectedScore,
          comment: comment.isEmpty ? null : comment,
        );
      },
    );
  }
}
