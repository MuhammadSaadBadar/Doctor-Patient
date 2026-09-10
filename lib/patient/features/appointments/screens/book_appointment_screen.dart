// lib/patient/features/appointments/screens/book_appointment_screen.dart

import 'package:doctor/core/localization/translation_keys.dart';
import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:doctor/patient/features/appointments/controllers/book_appointment_controller.dart';
import 'package:doctor/patient/features/appointments/widgets/booking_doctor_card.dart';
import 'package:doctor/patient/features/appointments/widgets/booking_fee_summary.dart';
import 'package:doctor/patient/features/appointments/widgets/booking_section_header.dart';
import 'package:doctor/patient/features/appointments/widgets/booking_selection_card.dart';
import 'package:doctor/patient/features/appointments/widgets/booking_time_slot.dart';
import 'package:doctor/patient/features/appointments/widgets/booking_type_option.dart';
import 'package:doctor/patient/features/doctors/widgets/doctor_address_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookAppointmentScreen extends GetView<BookAppointmentController> {
  const BookAppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: PatientTopAppBar(
        title: TranslationKeys.bookingBookAppointment.tr,
        trailingActions: [
          IconButton(
            icon: Icon(
              Icons.help_outline_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              Get.snackbar(
                TranslationKeys.bookingHelp.tr,
                TranslationKeys.bookingHelpDesc.tr,
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 3),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.doctor.value == null) {
          return _buildLoadingState(context);
        }

        if (controller.hasError.value && controller.doctor.value == null) {
          return _buildErrorState(context);
        }

        final doctor = controller.doctor.value;
        if (doctor == null) {
          return _buildEmptyState(context);
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BookingDoctorCard(doctor: doctor),
                    const SizedBox(height: 24),
                    _buildTypeSelection(context),
                    const SizedBox(height: 24),
                    Obx(
                      () => controller.selectedType.value == 'in_person'
                          ? DoctorAddressCard(
                              area:
                                  controller.doctor.value?.doctorProfile?.area,
                              city:
                                  controller.doctor.value?.doctorProfile?.city,
                              latitude: controller
                                  .doctor
                                  .value
                                  ?.doctorProfile
                                  ?.latitude,
                              longitude: controller
                                  .doctor
                                  .value
                                  ?.doctorProfile
                                  ?.longitude,
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 24),
                    _buildDateSelection(context),
                    const SizedBox(height: 24),
                    _buildTimeSelection(context),
                    const SizedBox(height: 24),
                    _buildReasonField(context),
                    const SizedBox(height: 24),
                    Obx(
                      () => BookingFeeSummary(
                        doctor: doctor,
                        paymentMethod: controller.paymentMethod.value,
                        consultationFee: controller.consultationFeeDisplay,
                        totalPayable: controller.totalPayableDisplay,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              TranslationKeys.appointmentsConfirmationNotice.tr,
                              style: TextStyle(
                                fontSize: textScale.scale(11).clamp(9.0, 12.0),
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _buildStickyBookButton(context),
          ],
        );
      }),
    );
  }

  // ==================== TYPE SELECTION ====================

  Widget _buildTypeSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BookingSectionHeader(
          title: TranslationKeys.appointmentsAppointmentType.tr,
          icon: Icons.event_available_rounded,
        ),
        const SizedBox(height: 12),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: BookingTypeOption(
                  type: 'in_person',
                  label: TranslationKeys.bookingInPerson.tr,
                  icon: Icons.local_hospital_rounded,
                  color: Colors.blue.shade600,
                  isSelected: controller.selectedType.value == 'in_person',
                  onTap: () => controller.selectedType.value = 'in_person',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BookingTypeOption(
                  type: 'video_consultation',
                  label: TranslationKeys.bookingVideo.tr,
                  icon: Icons.videocam_rounded,
                  color: Colors.purple.shade600,
                  isSelected:
                      controller.selectedType.value == 'video_consultation',
                  onTap: () =>
                      controller.selectedType.value = 'video_consultation',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== DATE SELECTION ====================

  Widget _buildDateSelection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BookingSectionHeader(
          title: TranslationKeys.bookingSelectDate.tr,
          icon: Icons.calendar_today_rounded,
        ),
        const SizedBox(height: 12),
        Obx(
          () => BookingSelectionCard(
            onTap: () => controller.pickDate(context),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    size: 20,
                    color: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    controller.selectedDateDisplay,
                    style: TextStyle(
                      fontSize: textScale.scale(14).clamp(12.0, 16.0),
                      fontWeight: FontWeight.w500,
                      color: controller.selectedDate.value != null
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== TIME SELECTION ====================

  Widget _buildTimeSelection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // ✅ Added
      children: [
        BookingSectionHeader(
          title: TranslationKeys.bookingSelectTime.tr,
          icon: Icons.access_time_rounded,
        ),
        const SizedBox(height: 12),
        Obx(
          () => BookingSelectionCard(
            onTap: () => controller.pickTime(context),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.access_time_rounded,
                    size: 20,
                    color: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    controller.selectedTimeDisplay,
                    style: TextStyle(
                      fontSize: textScale.scale(14).clamp(12.0, 16.0),
                      fontWeight: FontWeight.w500,
                      color: controller.selectedTime.value != null
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          TranslationKeys.appointmentsAvailableTimeSlots.tr,
          style: TextStyle(
            fontSize: textScale.scale(12).clamp(10.0, 13.0),
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        // ✅ Fixed: Use SizedBox with explicit height for horizontal ListView
        SizedBox(
          height: 50, // Fixed height for horizontal ListView
          child: Obx(
            () => ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: controller.timeSlots.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final slot = controller.timeSlots[index];
                final isSelected =
                    controller.selectedTime.value != null &&
                    controller.selectedTime.value!.hour == slot.hour &&
                    controller.selectedTime.value!.minute == slot.minute;
                return BookingTimeSlot(
                  time: slot,
                  isSelected: isSelected,
                  onTap: () => controller.selectedTime.value = slot,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
  // ==================== REASON FIELD ====================

  Widget _buildReasonField(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BookingSectionHeader(
          title: TranslationKeys.bookingReason.tr,
          icon: Icons.note_rounded,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.reasonController,
          maxLines: 3,
          style: TextStyle(
            fontSize: textScale.scale(13).clamp(11.0, 15.0),
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: TranslationKeys.bookingReasonHint.tr,
            hintStyle: TextStyle(
              fontSize: textScale.scale(12).clamp(10.0, 14.0),
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.15),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.15),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerLowest,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  // ==================== STICKY BOOK BUTTON ====================

  Widget _buildStickyBookButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBookingProgress(context),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.canBook
                      ? controller.showBookingConfirmationDialog
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.canBook
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.12),
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: controller.canBook ? 4 : 0,
                    disabledBackgroundColor: colorScheme.onSurface.withValues(
                      alpha: 0.08,
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 20,
                              color: controller.canBook
                                  ? colorScheme.onPrimary
                                  : colorScheme.onPrimary.withValues(
                                      alpha: 0.4,
                                    ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              TranslationKeys.appointmentsConfirmBooking.tr,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingProgress(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasDoctor = controller.doctor.value != null;
    final hasType = controller.selectedType.value.isNotEmpty;
    final hasDate = controller.selectedDate.value != null;
    final hasTime = controller.selectedTime.value != null;

    final steps = [hasDoctor, hasType, hasDate, hasTime];

    return Row(
      children: [
        ...List.generate(4, (index) {
          final isComplete = steps[index];
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isComplete
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  child: Center(
                    child: isComplete
                        ? Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: colorScheme.onPrimary,
                          )
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                  ),
                ),
                if (index < 3)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: steps[index] && steps[index + 1]
                          ? colorScheme.primary
                          : colorScheme.outline.withValues(alpha: 0.15),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ==================== STATE WIDGETS ====================

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
              color: colorScheme.primaryContainer.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading doctor details...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
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
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.3),
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
              onPressed: controller.loadDoctor,
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
              child: Text(TranslationKeys.commonTryAgain.tr),
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
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medical_services_rounded,
                size: 40,
                color: colorScheme.primary.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Doctor Not Found',
              style: TextStyle(
                fontSize: textScale.scale(18).clamp(16.0, 20.0),
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                fontFamily: 'PlayfairDisplay',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The doctor you\'re looking for could not be found.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: textScale.scale(12).clamp(10.0, 14.0),
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.navigateBack,
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
              child: Text(TranslationKeys.appointmentsBackToSearch.tr),
            ),
          ],
        ),
      ),
    );
  }
}
