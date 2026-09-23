// lib/patient/features/appointments/controllers/book_appointment_controller.dart

import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/patient/features/appointments/models/platform_payment_method.dart';
import 'package:doctor/patient/features/appointments/repositories/appointment_repository.dart';
import 'package:doctor/patient/features/doctors/models/doctor.dart';
import 'package:doctor/patient/features/doctors/repositories/doctor_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BookAppointmentController extends GetxController {
  final AppointmentRepository _appointmentRepository =
      Get.find<AppointmentRepository>();
  final DoctorRepository _doctorRepository = Get.find<DoctorRepository>();

  final int doctorId;

  BookAppointmentController({required this.doctorId});

  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final loadingPaymentMethod = false.obs;

  final doctor = Rx<Doctor?>(null);
  final paymentMethod = Rx<PlatformPaymentMethod?>(null);
  final selectedDate = Rx<DateTime?>(null);
  final selectedTime = Rx<TimeOfDay?>(null);
  final selectedType = 'in_person'.obs;
  final reasonController = TextEditingController();

  // Available time slots - loaded from repository (backend when supported)
  final timeSlots = <TimeOfDay>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDoctor();
    loadPaymentMethods();
    _loadDefaultTimeSlots();
  }

  void _loadDefaultTimeSlots() {
    // Use repository's default slots (will be replaced with API call when backend supports it)
    timeSlots.value = _appointmentRepository.getDefaultTimeSlots();
  }

  Future<void> loadDoctor() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await _doctorRepository.getDoctorById(doctorId);
      if (result != null) {
        doctor.value = result;
        debugPrint('[BOOK_APPOINTMENT] Loaded doctor: ${result.fullName}');
      } else {
        hasError.value = true;
        errorMessage.value = 'Doctor not found.';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load doctor details.';
      debugPrint('[BOOK_APPOINTMENT] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPaymentMethods() async {
    loadingPaymentMethod.value = true;

    try {
      final result = await _appointmentRepository.getPaymentMethods();
      if (result != null) {
        paymentMethod.value = result;
        debugPrint('[BOOK_APPOINTMENT] Loaded payment methods');
      }
    } catch (e) {
      debugPrint('[BOOK_APPOINTMENT] Error loading payment methods: $e');
    } finally {
      loadingPaymentMethod.value = false;
    }
  }

  Future<void> loadTimeSlotsForDate(DateTime date) async {
    // TODO: When backend supports doctor availability, fetch actual slots
    // timeSlots.value = await _appointmentRepository.getAvailableTimeSlots(
    //   doctorId: doctorId,
    //   date: date,
    // );
    // For now, use default slots
    _loadDefaultTimeSlots();
  }

  String get formattedFee {
    final fee = doctor.value?.doctorProfile?.consultationFee;
    if (fee == null) return 'Free';
    return 'Rs. ${double.tryParse(fee)?.toStringAsFixed(0) ?? fee}';
  }

  double? get consultationFeeValue {
    final fee = doctor.value?.doctorProfile?.consultationFee;
    if (fee == null) return null;
    return double.tryParse(fee);
  }

  double get platformCommission {
    final fee = consultationFeeValue ?? 0;
    final commissionPercent =
        paymentMethod.value?.commissionPercentageValue ?? 0;
    return fee * (commissionPercent / 100);
  }

  double get totalPayable {
    final fee = consultationFeeValue ?? 0;
    return fee + platformCommission;
  }

  String get totalPayableDisplay {
    if (doctor.value?.doctorProfile?.consultationFee == null) return 'Free';
    return 'Rs. ${totalPayable.toStringAsFixed(0)}';
  }

  String get consultationFeeDisplay {
    if (consultationFeeValue == null) return 'Free';
    return 'Rs. ${consultationFeeValue!.toStringAsFixed(0)}';
  }

  String get platformCommissionDisplay {
    if (consultationFeeValue == null) return 'Rs. 0';
    return 'Rs. ${platformCommission.toStringAsFixed(0)}';
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

  bool get canBook =>
      selectedDate.value != null &&
      selectedTime.value != null &&
      !isLoading.value;

  /// Returns the formatted clinic address for in-person appointments.
  String get formattedClinicAddress {
    final profile = doctor.value?.doctorProfile;
    if (profile == null || !profile.hasAddress) {
      return 'Address details will be shared upon confirmation';
    }
    return profile.formattedAddress;
  }

  /// Returns lat/lng for external navigation if available.
  double? get clinicLatitude => doctor.value?.doctorProfile?.latitude;
  double? get clinicLongitude => doctor.value?.doctorProfile?.longitude;

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
              // ✅ Header strip (the band with the selected date + edit icon)
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
              // ✅ Circle behind the selected day — null = transparent,
              //    so unselected days show the dark dialog surface instead
              //    of a white circle.
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
      selectedTime.value = null; // Reset time when date changes
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
            // ✅ Same override pattern as the date picker so the time
            //    dial and header match in dark mode.
            timePickerTheme: TimePickerThemeData(
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

  Future<void> bookAppointment() async {
    if (!canBook) return;

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await _appointmentRepository.bookAppointment(
        doctorId: doctorId,
        appointmentType: selectedType.value,
        scheduledAt: combinedDateTime,
        durationMinutes: 30,
        reason: reasonController.text.trim().isEmpty
            ? null
            : reasonController.text.trim(),
      );

      if (result != null) {
        // Navigate to Appointments screen, Unpaid filter, highlighting the new card.
        // The list will be refreshed from the backend by the Appointments controller.
        Get.offAllNamed(
          AppRoutes.patientAppointments,
          arguments: {
            'initialFilter': 'unpaid',
            'highlightAppointmentId': result.id,
          },
        );
        Get.snackbar(
          'Appointment Created',
          'Your appointment is unpaid. Pay the consultation fee to confirm it with the doctor.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to book appointment. Please try again.';
        Get.snackbar(
          'Error',
          'Failed to book appointment. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Something went wrong. Please try again.';
      debugPrint('[BOOK_APPOINTMENT] Error: $e');
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

  Future<void> showBookingConfirmationDialog() async {
    if (!canBook) return;

    final doctorName = doctor.value?.fullName ?? 'the doctor';
    final spec = doctor.value?.doctorProfile?.specialization ?? 'Specialist';
    final dateText = selectedDateDisplay;
    final timeText = selectedTimeDisplay;
    final typeLabel = selectedType.value == 'video_consultation'
        ? 'Video Consultation'
        : 'In-Person Visit';

    final context = Get.context!;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pm = paymentMethod.value;

    // ✅ Semantic green / orange that flip with brightness
    final greenFg = isDark ? Colors.green.shade300 : Colors.green.shade800;
    final orangeFg = isDark ? Colors.orange.shade300 : Colors.orange.shade800;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        // ✅ Dialog background = colorScheme.background
        backgroundColor: colorScheme.background,
        // ✅ Kill M3's warm surface tint (the "cream" culprit)
        surfaceTintColor: Colors.transparent,
        // ✅ Theme-aware elevation shadow
        elevation: isDark ? 0 : 6,
        shadowColor: isDark ? Colors.transparent : colorScheme.shadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // ✅ Stronger tint in dark so the badge is visible
                color: colorScheme.primary.withValues(
                  alpha: isDark ? 0.20 : 0.12,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_available_rounded,
                color: colorScheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Confirm Booking',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You are about to book a $typeLabel appointment with Dr. $doctorName ($spec) on $dateText at $timeText.',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // ─────────────────────────────────────────────
              // Fee summary panel
              // ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  // ✅ Dark: primary-tinted gradient over background;
                  //    Light: primaryContainer tint
                  gradient: isDark
                      ? LinearGradient(
                          begin: AlignmentDirectional.topStart,
                          end: AlignmentDirectional.bottomEnd,
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.10),
                            colorScheme.primaryContainer.withValues(
                              alpha: 0.06,
                            ),
                          ],
                        )
                      : null,
                  color: !isDark
                      ? colorScheme.primaryContainer.withValues(alpha: 0.20)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  border: isDark
                      ? Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          width: 1,
                        )
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _dialogRow(
                      'Doctor Consultation Fee',
                      consultationFeeDisplay,
                    ),
                    const SizedBox(height: 6),
                    _dialogRow(
                      'Platform Commission',
                      platformCommissionDisplay,
                    ),
                    Divider(height: 18, color: colorScheme.outlineVariant),
                    _dialogRow(
                      'Total Payable Amount',
                      totalPayableDisplay,
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ─────────────────────────────────────────────
              // Payment method panel
              // ─────────────────────────────────────────────
              if (pm != null && pm.hasAnyMethod) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // ✅ Semantic green that flips with brightness
                    color: Colors.green.withValues(alpha: isDark ? 0.14 : 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withValues(
                        alpha: isDark ? 0.40 : 0.30,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 18,
                            color: greenFg,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Payment Method',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: greenFg,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (pm.hasJazzCash) ...[
                        _paymentDetailRow(
                          'JazzCash',
                          '${pm.jazzcashNumber} - ${pm.jazzcashAccountTitle}',
                        ),
                        const SizedBox(height: 6),
                      ],
                      if (pm.hasEasyPaisa) ...[
                        _paymentDetailRow(
                          'EasyPaisa',
                          '${pm.easypaisaNumber} - ${pm.easypaisaAccountTitle}',
                        ),
                        const SizedBox(height: 6),
                      ],
                      if (pm.hasBank) ...[
                        _paymentDetailRow(
                          'Bank',
                          '${pm.bankName} - ${pm.bankAccountNumber}',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // ─────────────────────────────────────────────
              // Warning panel
              // ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  // ✅ Semantic orange that flips with brightness
                  color: Colors.orange.withValues(alpha: isDark ? 0.14 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(
                      alpha: isDark ? 0.40 : 0.30,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, size: 18, color: orangeFg),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Booking the appointment is NOT the same as paying for it. '
                        'After booking you must pay the total amount to the platform account '
                        'and wait for admin verification before the doctor confirms your appointment.',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<bool>(result: false),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurfaceVariant,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back<bool>(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Confirm & Continue'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (confirmed == true) {
      await bookAppointment();
    }
  }

  Widget _dialogRow(String label, String value, {bool isTotal = false}) {
    final colorScheme = Get.theme.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: FontWeight.w700,
            color: isTotal ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _paymentDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Get.theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Get.theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  void navigateBack() {
    Get.back();
  }

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }
}
