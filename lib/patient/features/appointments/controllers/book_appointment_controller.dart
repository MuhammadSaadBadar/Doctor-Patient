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
    final commissionPercent = paymentMethod.value?.commissionPercentageValue ?? 0;
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
    final picked = await showDatePicker(
      context: context,
      initialDate:
          selectedDate.value ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: Theme.of(context).colorScheme.primary,
          ),
        ),
        child: child!,
      ),
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

    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime.value ?? TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: Theme.of(context).colorScheme.primary,
          ),
        ),
        child: child!,
      ),
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

  /// Confirmation dialog showing total payable amount and platform payment method.
  Future<void> showBookingConfirmationDialog() async {
    if (!canBook) return;

    final doctorName = doctor.value?.fullName ?? 'the doctor';
    final spec = doctor.value?.doctorProfile?.specialization ?? 'Specialist';
    final dateText = selectedDateDisplay;
    final timeText = selectedTimeDisplay;
    final typeLabel = selectedType.value == 'video_consultation'
        ? 'Video Consultation'
        : 'In-Person Visit';

    final colorScheme = Get.theme.colorScheme;
    final pm = paymentMethod.value;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_available_rounded,
                color: colorScheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            const Text('Confirm Booking'),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _dialogRow('Doctor Consultation Fee', consultationFeeDisplay),
                    const SizedBox(height: 6),
                    _dialogRow('Platform Commission', platformCommissionDisplay),
                    const Divider(height: 18),
                    _dialogRow(
                      'Total Payable Amount',
                      totalPayableDisplay,
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (pm != null && pm.hasAnyMethod) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 18,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Payment Method',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (pm.hasJazzCash) ...[
                        _paymentDetailRow('JazzCash', '${pm.jazzcashNumber} - ${pm.jazzcashAccountTitle}'),
                        const SizedBox(height: 6),
                      ],
                      if (pm.hasEasyPaisa) ...[
                        _paymentDetailRow('EasyPaisa', '${pm.easypaisaNumber} - ${pm.easypaisaAccountTitle}'),
                        const SizedBox(height: 6),
                      ],
                      if (pm.hasBank) ...[
                        _paymentDetailRow('Bank', '${pm.bankName} - ${pm.bankAccountNumber}'),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: Colors.orange.shade800,
                    ),
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
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
          ),
        ),
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
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Get.theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
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
