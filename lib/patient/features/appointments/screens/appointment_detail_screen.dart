// lib/patient/features/appointments/screens/appointment_detail_screen.dart

import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/core/widgets/doctor_avatar.dart';
import 'package:doctor/patient/features/appointments/controllers/appointment_detail_controller.dart';
import 'package:doctor/patient/features/appointments/models/appointment.dart';
import 'package:doctor/patient/features/doctors/widgets/doctor_address_card.dart';
import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppointmentDetailScreen extends GetView<AppointmentDetailController> {
  const AppointmentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: PatientTopAppBar(
        title: 'Appointment Details',
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState(context);
        }

        if (controller.hasError.value) {
          return _buildErrorState(context);
        }

        final appointment = controller.appointment.value;
        if (appointment == null) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // ✅ Added
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

  Widget _buildStatusBadge(BuildContext context, Appointment appointment) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: appointment.statusColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: appointment.statusColor.withValues(alpha: 0.3),
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
                color: appointment.statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              appointment.statusLabel,
              style: TextStyle(
                fontSize: textScale.scale(14).clamp(12.0, 16.0),
                fontWeight: FontWeight.w700,
                color: appointment.statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorSection(BuildContext context, Appointment appointment) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
              mainAxisSize: MainAxisSize.min, // ✅ Added
              children: [
                Text(
                  // ✅ Removed Flexible wrapper
                  appointment.doctorFullName,
                  style: TextStyle(
                    fontSize: textScale.scale(16).clamp(14.0, 18.0),
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  // ✅ Removed Flexible wrapper
                  appointment.doctorSpecialty,
                  style: TextStyle(
                    fontSize: textScale.scale(12).clamp(10.0, 14.0),
                    color: colorScheme.primary,
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
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        appointment.typeLabel,
                        style: TextStyle(
                          fontSize: textScale.scale(11).clamp(9.0, 13.0),
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
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, Appointment appointment) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ✅ Added
        children: [
          Text(
            'Appointment Details',
            style: TextStyle(
              fontSize: textScale.scale(14).clamp(12.0, 16.0),
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            Icons.calendar_today_rounded,
            'Date',
            appointment.formattedDate,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            context,
            Icons.access_time_rounded,
            'Time',
            appointment.timeRange,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            context,
            Icons.timer_rounded,
            'Duration',
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
              'Meeting Link',
              'Tap to join',
            ),
          ],
          if (appointment.reason != null && appointment.reason!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              Icons.note_rounded,
              'Reason',
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
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // ✅ Added
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: textScale.scale(11).clamp(9.0, 12.0),
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: textScale.scale(12).clamp(10.0, 14.0),
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection(BuildContext context, Appointment appointment) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);
    final payment = appointment.payment!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: controller.paymentStatusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ✅ Added
        children: [
          Row(
            children: [
              Text(
                'Payment',
                style: TextStyle(
                  fontSize: textScale.scale(14).clamp(12.0, 16.0),
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: controller.paymentStatusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  controller.paymentStatusLabel,
                  style: TextStyle(
                    fontSize: textScale.scale(11).clamp(9.0, 12.0),
                    fontWeight: FontWeight.w600,
                    color: controller.paymentStatusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPaymentRow(
            context,
            'Consultation Fee',
            payment.formattedDoctorFee,
          ),
          const SizedBox(height: 8),
          _buildPaymentRow(
            context,
            'Platform Fee',
            payment.formattedCommission,
          ),
          const Divider(height: 24),
          _buildPaymentRow(
            context,
            'Total Amount',
            payment.formattedTotal,
            isTotal: true,
          ),
          const SizedBox(height: 12),
          Text(
            controller.paymentStatusDisplay,
            style: TextStyle(
              fontSize: textScale.scale(12).clamp(10.0, 13.0),
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (payment.paymentReference.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Ref: ${payment.paymentReference}',
              style: TextStyle(
                fontSize: textScale.scale(11).clamp(9.0, 12.0),
                color: colorScheme.onSurfaceVariant,
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
    final colorScheme = Theme.of(context).colorScheme;
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
              color: isTotal
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
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
            color: isTotal ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorContactSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ✅ Added
        children: [
          Row(
            children: [
              Icon(Icons.contact_phone_rounded, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Doctor Contact',
                style: TextStyle(
                  fontSize: textScale.scale(14).clamp(12.0, 16.0),
                  fontWeight: FontWeight.w700,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  controller.doctorPhone,
                  style: TextStyle(
                    fontSize: textScale.scale(14).clamp(12.0, 16.0),
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorNotesSection(
    BuildContext context,
    Appointment appointment,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ✅ Added
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_information_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Doctor Notes',
                style: TextStyle(
                  fontSize: textScale.scale(14).clamp(12.0, 16.0),
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
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
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationSection(
    BuildContext context,
    Appointment appointment,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ✅ Added
        children: [
          Row(
            children: [
              Icon(Icons.cancel_rounded, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                'Cancellation Reason',
                style: TextStyle(
                  fontSize: textScale.scale(14).clamp(12.0, 16.0),
                  fontWeight: FontWeight.w700,
                  color: Colors.red.shade800,
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
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Appointment appointment) {
    final colorScheme = Theme.of(context).colorScheme;
    final buttons = <Widget>[];

    if (controller.canCancel) {
      buttons.add(
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.cancel_rounded, size: 20),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _showCancelDialog(context, appointment),
          ),
        ),
      );
    }

    if (controller.canReschedule) {
      buttons.add(const SizedBox(width: 12));
      buttons.add(
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.schedule_rounded, size: 20),
            label: const Text('Reschedule'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _navigateToReschedule(appointment),
          ),
        ),
      );
    }

    if (controller.canPayNow) {
      buttons.add(const SizedBox(width: 12));
      buttons.add(
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.payment_rounded, size: 20),
            label: const Text('Pay Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _markPaymentAsPaid(appointment),
          ),
        ),
      );
    }

    if (controller.canRate) {
      buttons.add(const SizedBox(width: 12));
      buttons.add(
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.star_rounded, size: 20),
            label: const Text('Rate'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.amber.shade700,
              side: BorderSide(color: Colors.amber.shade700, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _showRatingDialog(context, appointment),
          ),
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: 12, runSpacing: 12, children: buttons);
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
              color: colorScheme.primaryContainer.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading appointment...',
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // ✅ Added
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
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
                fontSize: textScale.scale(16).clamp(14.0, 18.0),
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: textScale.scale(12).clamp(10.0, 14.0),
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.refreshData,
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

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // ✅ Added
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 64,
              color: colorScheme.outline.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Appointment Not Found',
              style: TextStyle(
                fontSize: textScale.scale(16).clamp(14.0, 18.0),
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The appointment you\'re looking for could not be found.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: textScale.scale(12).clamp(10.0, 14.0),
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
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
              child: const Text('Back to Appointments'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, Appointment appointment) {
    final colorScheme = Theme.of(context).colorScheme;
    final reasonController = TextEditingController();

    Get.defaultDialog(
      title: 'Cancel Appointment',
      titleStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Are you sure you want to cancel your appointment with ${appointment.doctorFullName} on ${appointment.formattedDate} at ${appointment.formattedTime}?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: reasonController,
            decoration: InputDecoration(
              labelText: 'Reason (optional)',
              hintText: 'e.g., scheduling conflict, feeling better',
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
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;
    int selectedScore = 5;
    final commentController = TextEditingController();

    Get.defaultDialog(
      title: 'Rate Your Appointment',
      titleStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'How was your appointment with ${appointment.doctorFullName}?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final star = index + 1;
              return GestureDetector(
                onTap: () => selectedScore = star,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    star <= selectedScore
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 36,
                    color: star <= selectedScore
                        ? Colors.amber
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: commentController,
            decoration: InputDecoration(
              labelText: 'Comment (optional)',
              hintText: 'Share your experience...',
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
      confirmTextColor: Colors.white,
      buttonColor: Colors.amber.shade700,
      cancelTextColor: colorScheme.onSurface,
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
