// lib/patient/features/appointments/screens/reschedule_appointment_screen.dart

import 'package:doctor/core/localization/translation_keys.dart';
import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:doctor/patient/features/appointments/controllers/reschedule_appointment_controller.dart';
import 'package:doctor/patient/features/appointments/models/appointment.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RescheduleAppointmentScreen
    extends GetView<RescheduleAppointmentController> {
  const RescheduleAppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // ✅ surface, not deprecated background
      backgroundColor: colorScheme.background,
      appBar: PatientTopAppBar(title: TranslationKeys.bookingReschedule.tr),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.appointment.value == null) {
          return _buildLoadingState(context);
        }

        if (controller.hasError.value && controller.appointment.value == null) {
          return _buildErrorState(context);
        }

        final appointment = controller.appointment.value;
        if (appointment == null) {
          return _buildEmptyState(context);
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCurrentAppointmentCard(context, appointment),
                    const SizedBox(height: 24),
                    _buildDateSelection(context),
                    const SizedBox(height: 24),
                    _buildTimeSelection(context),
                    const SizedBox(height: 24),
                    _buildWarningCard(context),
                  ],
                ),
              ),
            ),
            _buildStickyRescheduleButton(context),
          ],
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Shared helpers (same pattern as AppointmentDetailScreen)
  // ─────────────────────────────────────────────────────────────

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Card decoration — gradient in dark, solid in light.
  /// Matches `SettingsSection`, `_buildProfileSummaryCard`, etc.
  BoxDecoration _cardDecoration(
    BuildContext context, {
    double radius = 16,
    Border? border,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    return BoxDecoration(
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
      borderRadius: BorderRadius.circular(radius),
      border:
          border ??
          Border.all(
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

  /// Returns a hue that stays readable on both light and dark backgrounds.
  Color _semanticFg(BuildContext context, Color base) {
    final isDark = _isDark(context);
    if (base == Colors.orange)
      return isDark ? Colors.orange.shade300 : Colors.orange.shade800;
    if (base == Colors.amber)
      return isDark ? Colors.amber.shade200 : Colors.amber.shade800;
    return base;
  }

  Color _semanticBg(BuildContext context, Color base) {
    final isDark = _isDark(context);
    return base.withOpacity(isDark ? 0.16 : 0.08);
  }

  Color _semanticBorder(BuildContext context, Color base) {
    final isDark = _isDark(context);
    return base.withOpacity(isDark ? 0.45 : 0.30);
  }

  // ─────────────────────────────────────────────────────────────
  // Current appointment card
  // ─────────────────────────────────────────────────────────────

  Widget _buildCurrentAppointmentCard(
    BuildContext context,
    Appointment appointment,
  ) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // ✅ Semantic orange tint that flips with brightness
                  color: _semanticBg(context, Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  size: 20,
                  color: _semanticFg(context, Colors.orange),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      TranslationKeys.appointmentsCurrent.tr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      appointment.doctorFullName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            Icons.calendar_today_rounded,
            TranslationKeys.appointmentsDate.tr,
            appointment.formattedDate,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            context,
            Icons.access_time_rounded,
            TranslationKeys.appointmentsTime.tr,
            appointment.timeRange,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            context,
            Icons.timer_rounded,
            TranslationKeys.appointmentsDuration.tr,
            appointment.formattedDuration,
          ),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Date selection
  // ─────────────────────────────────────────────────────────────

  Widget _buildDateSelection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          TranslationKeys.appointmentsNewDate.tr,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => controller.pickDate(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            // ✅ Same card treatment as the rest of the screen
            decoration: _cardDecoration(context, radius: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    // ✅ Primary tint works in both themes because it sits
                    //    on top of the gradient card
                    color: isDark
                        ? cs.primary.withOpacity(0.18)
                        : cs.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    size: 20,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.selectedDateDisplay,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: controller.selectedDate.value != null
                          ? cs.onSurface
                          : cs.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Time selection
  // ─────────────────────────────────────────────────────────────

  Widget _buildTimeSelection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          TranslationKeys.appointmentsNewTime.tr,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => controller.pickTime(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(context, radius: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? cs.primary.withOpacity(0.18)
                        : cs.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.access_time_rounded,
                    size: 20,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.selectedTimeDisplay,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: controller.selectedTime.value != null
                          ? cs.onSurface
                          : cs.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          TranslationKeys.appointmentsAvailableSlots.tr,
          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: Obx(
            () => ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.timeSlots.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final slot = controller.timeSlots[index];
                final isSelected =
                    controller.selectedTime.value != null &&
                    controller.selectedTime.value!.hour == slot.hour &&
                    controller.selectedTime.value!.minute == slot.minute;

                // ✅ Chip: gradient tint when unselected in dark, solid
                //    primary when selected
                final chipDecoration = isSelected
                    ? BoxDecoration(
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: cs.primary, width: 2),
                      )
                    : BoxDecoration(
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
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? cs.primary.withOpacity(0.25)
                              : cs.outlineVariant.withOpacity(0.5),
                          width: 1,
                        ),
                      );

                return GestureDetector(
                  onTap: () => controller.selectedTime.value = slot,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: chipDecoration,
                    child: Center(
                      child: Text(
                        _formatTimeOfDay(slot),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? cs.onPrimary : cs.onSurface,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // ─────────────────────────────────────────────────────────────
  // Warning card — amber semantic, brightness-aware
  // ─────────────────────────────────────────────────────────────

  Widget _buildWarningCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _semanticBg(context, Colors.amber),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _semanticBorder(context, Colors.amber),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: _semanticFg(context, Colors.amber),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  TranslationKeys.appointmentsRescheduleImportant.tr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _semanticFg(context, Colors.amber),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  TranslationKeys.appointmentsRescheduleWarning.tr,
                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Sticky bottom button
  // ─────────────────────────────────────────────────────────────

  Widget _buildStickyRescheduleButton(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // ✅ In dark, use surfaceContainerHigh so the bar reads as
          //    "elevated above" the scaffold. In light, keep the 0.95
          //    translucency effect.
          color: isDark
              ? cs.surfaceContainerHigh
              : cs.surface.withOpacity(0.95),
          border: Border(
            top: BorderSide(
              color: isDark
                  ? cs.outlineVariant.withOpacity(0.4)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: cs.shadow.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.canReschedule
                  ? controller.rescheduleAppointment
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                disabledBackgroundColor: cs.onSurface.withOpacity(0.12),
                disabledForegroundColor: cs.onSurface.withOpacity(0.38),
              ),
              child: controller.isLoading.value
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        // ✅ Use onPrimary, not hardcoded white
                        color: cs.onPrimary,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      TranslationKeys.bookingConfirmReschedule.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
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
              color: cs.primaryContainer.withOpacity(isDark ? 0.35 : 0.2),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(color: cs.primary, strokeWidth: 3),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading appointment...',
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                // ✅ Correct contrast pair
                color: cs.onErrorContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.loadAppointment,
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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 64,
              color: cs.outline.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Appointment Not Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The appointment you\'re looking for could not be found.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.navigateBack,
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
}
