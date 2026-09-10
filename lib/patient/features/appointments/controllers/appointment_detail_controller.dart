// lib/patient/features/appointments/controllers/appointment_detail_controller.dart

import 'package:doctor/core/localization/translation_keys.dart';
import 'package:doctor/patient/features/appointments/models/appointment.dart';
import 'package:doctor/patient/features/appointments/models/appointment_payment.dart';
import 'package:doctor/patient/features/appointments/models/doctor_contact.dart';
import 'package:doctor/patient/features/appointments/models/doctor_payout.dart';
import 'package:doctor/patient/features/appointments/repositories/appointment_repository.dart';
import 'package:doctor/patient/features/doctors/models/doctor_profile.dart';
import 'package:doctor/patient/features/doctors/repositories/doctor_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppointmentDetailController extends GetxController {
  final AppointmentRepository _repository = Get.find<AppointmentRepository>();
  final DoctorRepository _doctorRepository = Get.find<DoctorRepository>();

  final int appointmentId;

  AppointmentDetailController({required this.appointmentId});

  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final appointment = Rx<Appointment?>(null);
  final doctorProfile = Rx<DoctorProfile?>(null);

  @override
  void onInit() {
    super.onInit();
    loadAppointment();
  }

  Future<void> loadAppointment() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await _repository.getAppointmentById(appointmentId);

      if (result != null) {
        appointment.value = result;
        debugPrint('[APPOINTMENT_DETAIL] Loaded appointment: ${result.id}');

        // Enrich with doctor profile for in-person appointments to get address
        if (result.appointmentType == 'in_person') {
          await _loadDoctorProfile(result.doctor.id);
        }
      } else {
        hasError.value = true;
        errorMessage.value = TranslationKeys.appointmentsNotFound.tr;
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Something went wrong. Please try again.';
      debugPrint('[APPOINTMENT_DETAIL] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadDoctorProfile(int doctorId) async {
    try {
      final doctor = await _doctorRepository.getDoctorById(doctorId);
      if (doctor != null) {
        doctorProfile.value = doctor.doctorProfile;
      }
    } catch (e) {
      debugPrint('[APPOINTMENT_DETAIL] Error loading doctor profile: $e');
    }
  }

  Future<void> refreshData() async {
    await loadAppointment();
  }

  // Computed getters for UI
  String get doctorName =>
      appointment.value?.doctorFullName ?? 'Unknown Doctor';
  String get doctorSpecialty => appointment.value?.doctorSpecialty ?? '';
  String get typeLabel => appointment.value?.typeLabel ?? '';
  String get status => appointment.value?.status ?? 'pending';
  bool get isConfirmed => appointment.value?.isConfirmed ?? false;
  bool get isPending => appointment.value?.isPending ?? true;
  bool get isCompleted => appointment.value?.isCompleted ?? false;
  bool get isCancelled => appointment.value?.isCancelled ?? false;
  DateTime get scheduledAt => appointment.value?.scheduledAt ?? DateTime.now();
  int get durationMinutes => appointment.value?.durationMinutes ?? 30;
  String get reason => appointment.value?.reason ?? '';
  String get meetingLink => appointment.value?.meetingLink ?? '';
  String get doctorNotes => appointment.value?.doctorNotes ?? '';
  String get cancellationReason => appointment.value?.cancellationReason ?? '';
  AppointmentPayment? get payment => appointment.value?.payment;
  DoctorContact? get doctorContact => appointment.value?.doctorContact;
  DoctorPayout? get doctorPayout => appointment.value?.doctorPayout;

  String get formattedDate {
    final d = scheduledAt;
    final months = [
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
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String get formattedTime {
    final d = scheduledAt;
    final hour = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final minute = d.minute.toString().padLeft(2, '0');
    final amPm = d.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $amPm';
  }

  String get paymentStatusLabel {
    if (payment == null) return TranslationKeys.appointmentsNoPayment.tr;
    switch (payment!.status) {
      case 'pending':
        return TranslationKeys.appointmentsUnpaid.tr;
      case 'awaiting_verification':
        return TranslationKeys.appointmentsAwaitingVerification.tr;
      case 'confirmed':
        return TranslationKeys.appointmentsPaid.tr;
      default:
        return payment!.status;
    }
  }

  Color get paymentStatusColor {
    if (payment == null) return Colors.grey;
    switch (payment!.status) {
      case 'pending':
        return Colors.orange;
      case 'awaiting_verification':
        return Colors.amber;
      case 'confirmed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String get paymentStatusDisplay {
    if (payment == null)
      return TranslationKeys.appointmentsNoPaymentRequired.tr;
    switch (payment!.status) {
      case 'pending':
        return TranslationKeys.appointmentsPaymentPending.tr;
      case 'awaiting_verification':
        return 'Awaiting admin verification';
      case 'confirmed':
        return TranslationKeys.appointmentsPaymentConfirmed.tr;
      default:
        return payment!.status;
    }
  }

  bool get canCancel => isPending || isConfirmed;
  bool get canReschedule => isPending || isConfirmed;
  bool get canPayNow => payment != null && payment!.isPending;
  bool get canRate =>
      isCompleted && (appointment.value?.payment?.isConfirmed ?? false);
  bool get showDoctorContact => appointment.value?.showDoctorContact ?? false;
  String get doctorPhone => appointment.value?.doctorPhone ?? 'N/A';
  bool get hasDoctorContact => appointment.value?.hasDoctorContact ?? false;

  /// Returns the formatted clinic address for in-person appointments.
  /// Falls back to a user-friendly message if address data is unavailable.
  String get clinicAddress {
    final profile = doctorProfile.value;
    if (profile == null || !profile.hasAddress) {
      return 'Address details will be shared upon confirmation';
    }
    return profile.formattedAddress;
  }

  /// Returns lat/lng for external navigation if available.
  double? get clinicLatitude => doctorProfile.value?.latitude;
  double? get clinicLongitude => doctorProfile.value?.longitude;

  // Action methods
  Future<void> cancelAppointment(String? reason) async {
    final currentAppointment = appointment.value;
    if (currentAppointment == null) return;

    try {
      final result = await _repository.cancelAppointment(
        currentAppointment.id,
        reason: reason,
      );
      if (result != null) {
        appointment.value = result;
        Get.snackbar(
          'Cancelled',
          'Appointment cancelled successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to cancel appointment. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('[APPOINTMENT_DETAIL] Cancel error: $e');
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> markPaymentAsPaid() async {
    final currentAppointment = appointment.value;
    if (currentAppointment == null) return;

    try {
      final result = await _repository.markPaymentAsPaid(currentAppointment.id);
      if (result != null) {
        appointment.value = result;
        Get.snackbar(
          'Payment Marked',
          'Payment marked as paid. Awaiting admin verification.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to mark payment. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('[APPOINTMENT_DETAIL] Mark payment error: $e');
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> rateAppointment(int score, {String? comment}) async {
    final currentAppointment = appointment.value;
    if (currentAppointment == null) return;

    try {
      final success = await _repository.rateAppointment(
        currentAppointment.id,
        score,
        comment: comment,
      );
      if (success) {
        Get.snackbar(
          'Thank You!',
          'Your rating has been submitted.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to submit rating. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('[APPOINTMENT_DETAIL] Rate error: $e');
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
