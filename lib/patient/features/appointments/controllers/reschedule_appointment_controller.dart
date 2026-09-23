// lib/patient/features/appointments/controllers/reschedule_appointment_controller.dart

import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/patient/features/appointments/models/appointment.dart';
import 'package:doctor/patient/features/appointments/repositories/appointment_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RescheduleAppointmentController extends GetxController {
  final AppointmentRepository _appointmentRepository =
      Get.find<AppointmentRepository>();

  final int appointmentId;

  RescheduleAppointmentController({required this.appointmentId});

  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final appointment = Rx<Appointment?>(null);
  final selectedDate = Rx<DateTime?>(null);
  final selectedTime = Rx<TimeOfDay?>(null);

  // Available time slots - loaded from repository (backend when supported)
  final timeSlots = <TimeOfDay>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAppointment();
    _loadDefaultTimeSlots();
  }

  void _loadDefaultTimeSlots() {
    // Use repository's default slots (will be replaced with API call when backend supports it)
    timeSlots.value = _appointmentRepository.getDefaultTimeSlots();
  }

  Future<void> loadAppointment() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await _appointmentRepository.getAppointmentById(
        appointmentId,
      );
      if (result != null) {
        appointment.value = result;
        // Pre-fill with current appointment date/time
        selectedDate.value = DateTime(
          result.scheduledAt.year,
          result.scheduledAt.month,
          result.scheduledAt.day,
        );
        selectedTime.value = TimeOfDay(
          hour: result.scheduledAt.hour,
          minute: result.scheduledAt.minute,
        );
        debugPrint('[RESCHEDULE] Loaded appointment: ${result.id}');
      } else {
        hasError.value = true;
        errorMessage.value = 'Appointment not found.';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load appointment.';
      debugPrint('[RESCHEDULE] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTimeSlotsForDate(DateTime date) async {
    // TODO: When backend supports doctor availability, fetch actual slots
    // if (appointment.value != null) {
    //   timeSlots.value = await _appointmentRepository.getAvailableTimeSlots(
    //     doctorId: appointment.value!.doctor.id,
    //     date: date,
    //   );
    // }
    // For now, use default slots
    _loadDefaultTimeSlots();
  }

  String get selectedDateDisplay {
    if (selectedDate.value == null) return 'Select Date';
    return DateFormat('EEEE, MMMM d, yyyy').format(selectedDate.value!);
  }

  String get selectedTimeDisplay {
    if (selectedTime.value == null) return 'Select Time';
    final hour = selectedTime.value!.hourOfPeriod == 0
        ? 12
        : selectedTime.value!.hourOfPeriod;
    final minute = selectedTime.value!.minute.toString().padLeft(2, '0');
    final period = selectedTime.value!.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  DateTime get combinedDateTime {
    final date = selectedDate.value ?? DateTime.now();
    final time = selectedTime.value ?? TimeOfDay.now();
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  bool get canReschedule =>
      selectedDate.value != null &&
      selectedTime.value != null &&
      !isLoading.value;

  Future<void> pickDate(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              // ✅ Dialog surface — matches scaffold in dark
              backgroundColor: isDark ? cs.background : cs.surface,
              // ✅ Header strip (top band with the selected date)
              headerBackgroundColor: isDark ? cs.background : cs.surface,
              headerForegroundColor: isDark ? cs.onBackground : cs.onSurface,
              // ✅ Day numbers
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return cs.onPrimary;
                }
                if (states.contains(WidgetState.disabled)) {
                  return (isDark ? cs.onBackground : cs.onSurface).withValues(
                    alpha: 0.38,
                  );
                }
                return isDark ? cs.onBackground : cs.onSurface;
              }),
              // ✅ Circle behind selected day — null = transparent so
              //    unselected days show the dark dialog bg, not a white circle
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return cs.primary;
                }
                return null;
              }),
              // ✅ Today's ring
              todayBorder: BorderSide(color: cs.primary, width: 1.5),
              todayForegroundColor: WidgetStatePropertyAll(cs.primary),
              // ✅ Weekday labels (Mon, Tue, Wed…)
              weekdayStyle: TextStyle(
                color: (isDark ? cs.onBackground : cs.onSurface).withValues(
                  alpha: 0.7,
                ),
                fontWeight: FontWeight.w600,
              ),
              // ✅ Month / year header
              yearForegroundColor: WidgetStatePropertyAll(
                isDark ? cs.onBackground : cs.onSurface,
              ),
              // ✅ Cancel / OK
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: cs.primary,
              ),
              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: cs.primary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      selectedDate.value = picked;
      selectedTime.value = null;
      await loadTimeSlotsForDate(picked);
    }
  }

  Future<void> pickTime(BuildContext context) async {
    if (selectedDate.value == null) {
      Get.snackbar(
        'Select Date First',
        'Please select a date before choosing time',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime.value ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              // ✅ Same treatment so the dial matches the date picker
              backgroundColor: isDark ? cs.background : cs.surface,
              hourMinuteColor: isDark
                  ? cs.primary.withValues(alpha: 0.18)
                  : cs.primaryContainer,
              hourMinuteTextColor: isDark
                  ? cs.onBackground
                  : cs.onPrimaryContainer,
              dialBackgroundColor: isDark
                  ? cs.primary.withValues(alpha: 0.12)
                  : cs.surfaceVariant,
              dialHandColor: cs.primary,
              dialTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return cs.onPrimary;
                }
                return isDark ? cs.onBackground : cs.onSurface;
              }),
              entryModeIconColor: isDark
                  ? cs.onBackground
                  : cs.onSurfaceVariant,
              helpTextStyle: TextStyle(
                color: (isDark ? cs.onBackground : cs.onSurface).withValues(
                  alpha: 0.7,
                ),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: cs.primary,
              ),
              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: cs.primary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      selectedTime.value = picked;
    }
  }

  Future<void> rescheduleAppointment() async {
    if (!canReschedule || appointment.value == null) return;

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await _appointmentRepository.rescheduleAppointment(
        appointmentId,
        newScheduledAt: combinedDateTime,
        durationMinutes: appointment.value!.durationMinutes,
      );

      if (result != null) {
        Get.back(result: true);
        Get.snackbar(
          'Rescheduled',
          'Appointment rescheduled successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        hasError.value = true;
        errorMessage.value =
            'Failed to reschedule appointment. Please try again.';
        Get.snackbar(
          'Error',
          'Failed to reschedule appointment. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Something went wrong. Please try again.';
      debugPrint('[RESCHEDULE] Error: $e');
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void navigateBack() {
    Get.back();
  }
}
