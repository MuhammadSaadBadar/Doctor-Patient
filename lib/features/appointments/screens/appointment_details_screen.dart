import 'package:doctor/core/widgets/bottom_nav_bar.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';
import 'package:doctor/core/widgets/top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/features/appointments/controllers/appointment_detail_controller.dart';
import 'package:doctor/features/appointments/models/appointment_schedule.dart';

class AppointmentDetailsScreen extends GetView<AppointmentDetailController> {
  final String? appointmentId;

  const AppointmentDetailsScreen({super.key, this.appointmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: const TopAppNavBar.gradient(
        title: 'Appointment Details',
        height: 64,
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) return _buildLoadingState();
        if (controller.hasError.value) return _buildErrorState(context);
        if (controller.appointment.value == null) return _buildEmptyState();

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 768;
              return isDesktop
                  ? _buildDesktopLayout(context)
                  : _buildMobileLayout(context);
            },
          ),
        );
      }),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  // ── Loading ─────────────────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.outlineSubtle,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading appointment details…',
            style: AppTheme.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ── Error ───────────────────────────────────────────────────────────────────

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Something went wrong',
              style: AppTheme.titleLarge.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              style: AppTheme.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () =>
                    controller.loadAppointmentDetails(appointmentId),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty ───────────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.primarySubtle,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: MaterialSymbolIcon(
                  'event_busy',
                  size: 40,
                  color: AppColors.primaryMuted,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Appointment Not Found',
              style: AppTheme.titleLarge.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              'The appointment you are looking for does not exist.',
              style: AppTheme.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Go Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Layouts ─────────────────────────────────────────────────────────────────

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 8, child: _buildLeftColumn(context)),
        const SizedBox(width: 24),
        Expanded(flex: 4, child: _buildRightColumn(context)),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildLeftColumn(context),
        const SizedBox(height: 16),
        _buildRightColumn(context),
      ],
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  BoxDecoration _cardShell(BuildContext context) =>
      AppTheme.cardDecoration(context: context);

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.primarySubtle,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppTheme.headlineSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _divider() => Container(height: 1, color: AppColors.outlineSubtle);

  // ── Left column ─────────────────────────────────────────────────────────────

  Widget _buildLeftColumn(BuildContext context) {
    return Column(
      children: [
        _buildPatientHeaderCard(),
        const SizedBox(height: 16),
        _buildAppointmentInfoCard(),
        const SizedBox(height: 16),
        _buildClinicalNotesCard(context),
      ],
    );
  }

  // ── Right column ────────────────────────────────────────────────────────────

  Widget _buildRightColumn(BuildContext context) {
    return Column(
      children: [
        _buildPaymentCard(context),
        const SizedBox(height: 16),
        _buildActionButtons(context),
      ],
    );
  }

  // ── Patient header card ──────────────────────────────────────────────────────

  Widget _buildPatientHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Obx(() {
        final appointment = controller.appointment.value!;
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 768;
            return isDesktop
                ? _buildPatientHeaderRow(appointment)
                : _buildPatientHeaderColumn(appointment);
          },
        );
      }),
    );
  }

  Widget _buildPatientHeaderRow(AppointmentSchedule appointment) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildPatientInfo(appointment)),
        const SizedBox(width: 12),
        _buildStatusChip(appointment),
      ],
    );
  }

  Widget _buildPatientHeaderColumn(AppointmentSchedule appointment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPatientInfo(appointment),
        const SizedBox(height: 14),
        _buildStatusChip(appointment),
      ],
    );
  }

  Widget _buildPatientInfo(AppointmentSchedule appointment) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.onPrimary.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.onPrimary.withOpacity(0.25),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              appointment.patientInitials,
              style: AppTheme.headlineSmall.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                appointment.patientName,
                style: AppTheme.headlineSmall.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                'ID: #PT-${appointment.id.toString().padLeft(4, '0')}',
                style: AppTheme.labelMedium.copyWith(
                  color: AppColors.onPrimary.withOpacity(0.65),
                ),
              ),
              const SizedBox(height: 3),
              Obx(() {
                final appt = controller.appointment.value;
                final pat = controller.patient.value;
                final ageText = pat != null && pat.age > 0 ? '${pat.age} years' : 'Age unknown';
                final phoneText = pat?.phoneNumber?.isNotEmpty == true ? pat!.phoneNumber! : 'Phone not available';
                return Text(
                  '$ageText • $phoneText',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppColors.onPrimary.withOpacity(0.55),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(AppointmentSchedule appointment) {
    final Color bgColor;
    final Color textColor;
    final IconData icon;

    switch (appointment.status) {
      case AppointmentStatus.confirmed:
        bgColor = AppColors.secondarySubtle;
        textColor = AppColors.secondary;
        icon = Icons.check_circle_rounded;
        break;
      case AppointmentStatus.completed:
        bgColor = AppColors.successContainer;
        textColor = AppColors.onSuccessContainer;
        icon = Icons.check_circle_rounded;
        break;
      case AppointmentStatus.pending:
        bgColor = AppColors.warningContainer;
        textColor = AppColors.onWarningContainer;
        icon = Icons.schedule_rounded;
        break;
      case AppointmentStatus.cancelled:
      case AppointmentStatus.noShow:
        bgColor = AppColors.errorContainer;
        textColor = AppColors.onErrorContainer;
        icon = Icons.cancel_rounded;
        break;
      default:
        bgColor = AppColors.surfaceVariant;
        textColor = AppColors.onSurfaceVariant;
        icon = Icons.help_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: textColor),
          const SizedBox(width: 6),
          Text(
            appointment.statusDisplay,
            style: AppTheme.labelMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ── Appointment info card ────────────────────────────────────────────────────

  Widget _buildAppointmentInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardShell(Get.context!),
      child: Obx(() {
        final appointment = controller.appointment.value!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Appointment Details', Icons.event_note_rounded),
            const SizedBox(height: 14),
            _divider(),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 768;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isDesktop ? 2 : 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3.5,
                  children: [
                    _buildInfoTile(
                      icon: Icons.calendar_today_rounded,
                      label: 'Date & Time',
                      value:
                          '${appointment.date.toString().split(' ')[0]} @ ${appointment.time}',
                    ),
                    _buildInfoTile(
                      icon:
                          appointment.type == AppointmentType.videoConsultation
                          ? Icons.videocam_rounded
                          : Icons.location_on_rounded,
                      label: 'Type & Duration',
                      value:
                          '${appointment.typeDisplay} • ${appointment.durationMinutes} Min',
                    ),
                    _buildInfoTile(
                      icon: Icons.medical_services_rounded,
                      label: 'Doctor',
                      value: 'Dr. ${appointment.doctorName}',
                    ),
                    if (appointment.reason.isNotEmpty)
                      _buildInfoTile(
                        icon: Icons.note_alt_rounded,
                        label: 'Reason',
                        value: appointment.reason,
                        isMultiLine: true,
                        isFullWidth: !isDesktop,
                      ),
                    if (appointment.type == AppointmentType.videoConsultation &&
                        appointment.meetingLink.isNotEmpty)
                      _buildInfoTile(
                        icon: Icons.link_rounded,
                        label: 'Meeting Link',
                        value: appointment.meetingLink,
                        isLink: true,
                        isFullWidth: true,
                      ),
                  ],
                );
              },
            ),
          ],
        );
      }),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    bool isLink = false,
    bool isMultiLine = false,
    bool isFullWidth = false,
  }) {
    final content = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLink ? AppColors.primary : AppColors.primarySubtle,
        borderRadius: BorderRadius.circular(12),
        border: isLink ? null : Border.all(color: AppColors.outlineSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isLink
                  ? AppColors.onPrimary.withOpacity(0.15)
                  : AppColors.surfaceContainerLowest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isLink ? AppColors.onPrimary : AppColors.primary,
              size: 17,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTheme.labelSmall.copyWith(
                    color: isLink
                        ? AppColors.onPrimary.withOpacity(0.65)
                        : AppColors.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTheme.bodyMedium.copyWith(
                    color: isLink ? AppColors.onPrimary : AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                    decoration: isLink ? TextDecoration.underline : null,
                  ),
                  maxLines: isMultiLine ? 3 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isLink)
            Icon(
              Icons.open_in_new_rounded,
              size: 16,
              color: AppColors.onPrimary.withOpacity(0.75),
            ),
        ],
      ),
    );

    if (!isLink) return content;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final url = Uri.parse(value);
          // Use url_launcher or similar
        },
        child: content,
      ),
    );
  }

  // ── Clinical notes card ──────────────────────────────────────────────────────

  Widget _buildClinicalNotesCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardShell(context),
      child: Obx(() {
        final appointment = controller.appointment.value!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionHeader(
                  'Clinical Notes',
                  Icons.medical_information_rounded,
                ),
                Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _showEditNotesDialog(context, appointment),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            size: 14,
                            color: AppColors.onPrimary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Edit Notes',
                            style: AppTheme.labelMedium.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineSubtle),
              ),
              child: Text(
                appointment.doctorNotes.isNotEmpty
                    ? appointment.doctorNotes
                    : 'No clinical notes available.',
                style: AppTheme.bodyMedium.copyWith(
                  height: 1.55,
                  color: appointment.doctorNotes.isNotEmpty
                      ? AppColors.onSurface
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ── Payment card ─────────────────────────────────────────────────────────────

  Widget _buildPaymentCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardShell(context),
      child: Obx(() {
        final appointment = controller.appointment.value!;
        final payment = appointment.payment;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionHeader('Payment Details', Icons.payments_rounded),
                if (payment != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _getPaymentStatusBg(payment.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      payment.statusDisplay,
                      style: AppTheme.labelMedium.copyWith(
                        color: _getPaymentStatusFg(payment.status),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            if (payment != null) ...[
              _buildPaymentRow(
                label: 'Consultation Fee',
                value: 'PKR ${payment.doctorFee}',
              ),
              const SizedBox(height: 8),
              _buildPaymentRow(
                label: 'Platform Commission (${payment.commissionPercentage}%)',
                value: '- PKR ${payment.commissionAmount}',
                isError: true,
              ),
              const SizedBox(height: 12),
              _divider(),
              const SizedBox(height: 12),

              // Total row
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildPaymentRow(
                  label: 'Total Amount',
                  value: 'PKR ${payment.totalAmount}',
                  isTotal: true,
                ),
              ),

              if (payment.paymentReference.isNotEmpty) ...[
                const SizedBox(height: 10),
                _buildPaymentRow(
                  label: 'Reference',
                  value: payment.paymentReference,
                  isSmall: true,
                ),
              ],
              if (payment.confirmedAt != null) ...[
                const SizedBox(height: 8),
                _buildPaymentRow(
                  label: 'Confirmed At',
                  value: _formatDate(payment.confirmedAt!),
                  isSmall: true,
                ),
              ],

              // Awaiting verification notice
              if (payment.status ==
                  AppointmentPaymentStatus.awaitingVerification) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warningContainer,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.30),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: AppColors.onWarningContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Patient has marked this as paid. Admin will verify payment and confirm the appointment.',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppColors.onWarningContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Confirmed notice
              if (payment.status == AppointmentPaymentStatus.confirmed) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.successContainer,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.30),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: AppColors.onSuccessContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Payment confirmed. Appointment is confirmed.',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppColors.onSuccessContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No payment required for this consultation.',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],

            // Doctor Payout Status (Phase 17)
            if (appointment.doctorPayout != null) ...[
              const SizedBox(height: 16),
              _divider(),
              const SizedBox(height: 12),
              _sectionHeader(
                'Payout Status',
                Icons.account_balance_wallet_rounded,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: appointment.doctorPayout!.statusColor.withOpacity(
                        0.15,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      appointment.doctorPayout!.statusDisplay,
                      style: AppTheme.labelMedium.copyWith(
                        color: appointment.doctorPayout!.statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'PKR ${appointment.doctorPayout!.amount}',
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],

            // Patient Contact (shown after payment verified)
            if (appointment.doctorContact != null &&
                appointment.doctorContact!.phoneNumber != null &&
                appointment.doctorContact!.phoneNumber!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _divider(),
              const SizedBox(height: 12),
              _sectionHeader('Patient Contact', Icons.phone_rounded),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        appointment.doctorContact!.phoneNumber!,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // TODO: Launch phone dialer
                      },
                      icon: Icon(
                        Icons.call_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      tooltip: 'Call Patient',
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      }),
    );
  } // <-- THIS WAS THE MISSING BRACE!

  Color _getPaymentStatusBg(AppointmentPaymentStatus status) {
    switch (status) {
      case AppointmentPaymentStatus.confirmed:
        return AppColors.successContainer;
      case AppointmentPaymentStatus.awaitingVerification:
        return AppColors.warningContainer;
      case AppointmentPaymentStatus.pending:
        return AppColors.errorContainer;
    }
  }

  Color _getPaymentStatusFg(AppointmentPaymentStatus status) {
    switch (status) {
      case AppointmentPaymentStatus.confirmed:
        return AppColors.onSuccessContainer;
      case AppointmentPaymentStatus.awaitingVerification:
        return AppColors.onWarningContainer;
      case AppointmentPaymentStatus.pending:
        return AppColors.onErrorContainer;
    }
  }

  Widget _buildPaymentRow({
    required String label,
    required String value,
    bool isError = false,
    bool isTotal = false,
    bool isSmall = false,
  }) {
    final double fontSize = isSmall ? 12 : (isTotal ? 15 : 14);
    final FontWeight weight = isTotal ? FontWeight.w700 : FontWeight.w400;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              fontSize: fontSize,
              fontWeight: weight,
              color: isTotal ? AppColors.onPrimary : AppColors.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              fontSize: fontSize,
              fontWeight: weight,
              color: isError
                  ? AppColors.error
                  : isTotal
                  ? AppColors.onPrimary
                  : AppColors.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  // ── Action buttons ───────────────────────────────────────────────────────────

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardShell(context),
      child: Obx(() {
        final appointment = controller.appointment.value;
        if (appointment == null) return const SizedBox.shrink();

        final status = appointment.status;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionHeader('Actions', Icons.touch_app_rounded),
            const SizedBox(height: 14),
            _divider(),
            const SizedBox(height: 14),

            if (status == AppointmentStatus.confirmed) ...[
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => _showCompleteConfirmation(context),
                  icon: const Icon(Icons.task_alt_rounded, size: 18),
                  label: Text(
                    'Complete Appointment',
                    style: AppTheme.labelLarge.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: AppColors.primary.withOpacity(
                      0.55,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            if (status != AppointmentStatus.completed &&
                status != AppointmentStatus.cancelled &&
                status != AppointmentStatus.noShow) ...[
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => _showRescheduleDialog(context),
                  icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                  label: Text(
                    'Reschedule',
                    style: AppTheme.labelLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.primarySubtle,
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary.withOpacity(0.30),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => _showCancelDialog(context),
                  icon: const Icon(Icons.cancel_rounded, size: 18),
                  label: Text(
                    'Cancel Appointment',
                    style: AppTheme.labelLarge.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.errorSubtle,
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error.withOpacity(0.35)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  // ── Dialog helpers ───────────────────────────────────────────────────────────

  Widget _dialogTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineSubtle),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: AppTheme.bodyMedium.copyWith(color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTheme.bodyMedium.copyWith(color: AppColors.outline),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  ShapeBorder _dialogShape() =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20));

  BoxDecoration _dialogDecoration() => BoxDecoration(
    color: AppColors.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(20),
  );

  TextStyle _dialogTitleStyle() =>
      AppTheme.titleLarge.copyWith(color: AppColors.primary);

  TextStyle _dialogBodyStyle() =>
      AppTheme.bodyMedium.copyWith(color: AppColors.onSurface);

  TextStyle _dialogCancelStyle() =>
      AppTheme.labelLarge.copyWith(color: AppColors.primaryMuted);

  // ── Dialogs ──────────────────────────────────────────────────────────────────

  void _showCancelDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: _dialogShape(),
        title: Text('Cancel Appointment', style: _dialogTitleStyle()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel this appointment?',
              style: _dialogBodyStyle(),
            ),
            const SizedBox(height: 14),
            Text(
              'Reason (Optional)',
              style: AppTheme.labelMedium.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            _dialogTextField(
              controller: reasonController,
              hintText: 'Enter cancellation reason...',
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep', style: _dialogCancelStyle()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.cancelAppointment(reasonController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Cancel Appointment',
              style: AppTheme.labelLarge.copyWith(
                color: AppColors.onError,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompleteConfirmation(BuildContext context) {
    final appointment = controller.appointment.value!;
    final isPending = appointment.status == AppointmentStatus.pending;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: _dialogShape(),
        title: Text(
          isPending ? 'Confirm Appointment' : 'Complete Appointment',
          style: _dialogTitleStyle(),
        ),
        content: Text(
          isPending
              ? 'Are you sure you want to confirm this appointment?'
              : 'Are you sure you want to mark this appointment as completed?',
          style: _dialogBodyStyle(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: _dialogCancelStyle()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (isPending) {
                controller.confirmAppointment();
              } else {
                controller.completeAppointment();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              isPending ? 'Confirm' : 'Complete',
              style: AppTheme.labelLarge.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRescheduleDialog(BuildContext context) {
    final appointment = controller.appointment.value!;
    DateTime selectedDate = appointment.scheduledAt;
    TimeOfDay selectedTime = TimeOfDay(
      hour: appointment.scheduledAt.hour,
      minute: appointment.scheduledAt.minute,
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.surfaceContainerLowest,
            shape: _dialogShape(),
            title: Text('Reschedule Appointment', style: _dialogTitleStyle()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPickerTile(
                  icon: Icons.calendar_today_rounded,
                  title: 'Select Date',
                  subtitle: selectedDate.toString().split(' ')[0],
                  onTap: () async {
                    final now = DateTime.now();
                    final firstDate = now;
                    final lastDate = now.add(const Duration(days: 365));

                    DateTime clampedInitialDate = selectedDate;
                    if (clampedInitialDate.isBefore(firstDate)) {
                      clampedInitialDate = firstDate;
                    } else if (clampedInitialDate.isAfter(lastDate)) {
                      clampedInitialDate = lastDate;
                    }

                    final date = await showDatePicker(
                      context: context,
                      initialDate: clampedInitialDate,
                      firstDate: firstDate,
                      lastDate: lastDate,
                    );
                    if (date != null) setState(() => selectedDate = date);
                  },
                ),
                const SizedBox(height: 8),
                _buildPickerTile(
                  icon: Icons.access_time_rounded,
                  title: 'Select Time',
                  subtitle:
                      '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) setState(() => selectedTime = time);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: _dialogCancelStyle()),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  final newDateTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );
                  controller.rescheduleAppointment(newDateTime);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Reschedule',
                  style: AppTheme.labelLarge.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPickerTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineSubtle),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.labelMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditNotesDialog(
    BuildContext context,
    AppointmentSchedule appointment,
  ) {
    final TextEditingController notesController = TextEditingController(
      text: appointment.doctorNotes,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: _dialogShape(),
        title: Text('Edit Clinical Notes', style: _dialogTitleStyle()),
        content: _dialogTextField(
          controller: notesController,
          hintText: 'Enter clinical notes...',
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: _dialogCancelStyle()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.updateDoctorNotes(notesController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Save Notes',
              style: AppTheme.labelLarge.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
