import 'package:doctor/core/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor/doctor/features/appointments/repositories/doc_appointment_repository.dart';
import 'package:doctor/doctor/features/appointments/models/doc_appointment_schedule.dart';
import 'package:doctor/doctor/features/patient/models/doc_patient.dart';
import 'package:doctor/doctor/features/patient/repositories/doc_patient_repository.dart';
import 'package:doctor/core/services/storage_service.dart';

class DoctorAppointmentDetailController extends GetxController {
  final DoctorAppointmentRepository _repository = DoctorAppointmentRepository();
  final DoctorPatientRepository _patientRepository = DoctorPatientRepository();
  final StorageService _storage = Get.find<StorageService>();

  final appointment = Rx<AppointmentSchedule?>(null);
  final patient = Rx<Patient?>(null);
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is String) {
      loadAppointmentDetails(args);
    } else if (args is Map && args.containsKey('id')) {
      loadAppointmentDetails(args['id'].toString());
    } else if (args is int) {
      loadAppointmentDetails(args.toString());
    }
  }

  Future<void> loadAppointmentDetails(String? id) async {
    if (id == null || id.isEmpty) {
      hasError.value = true;
      errorMessage.value = 'Invalid appointment ID';
      return;
    }

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await _repository.getAppointment(int.parse(id));
      if (result != null) {
        appointment.value = result;
        // Load patient details for age and phone
        _loadPatientDetails(result.patient.id);
      } else {
        hasError.value = true;
        errorMessage.value = 'Appointment not found';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value =
          'Failed to load appointment details. Please try again.';
      debugPrint('[APPOINTMENT_DETAIL] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadPatientDetails(int patientId) async {
    try {
      final patientData = await _patientRepository.getPatientById(patientId);
      if (patientData != null) {
        patient.value = Patient.fromPatientCard(patientData);
      }
    } catch (e) {
      debugPrint('[APPOINTMENT_DETAIL] Error loading patient: $e');
    }
  }

  Future<void> confirmAppointment() async {
    final currentAppointment = appointment.value;
    if (currentAppointment == null) return;

    isLoading.value = true;
    try {
      final result = await _repository.confirmAppointment(
        currentAppointment.id,
      );
      if (result != null) {
        appointment.value = result;
        Get.snackbar(
          'Success',
          'Appointment confirmed successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to confirm appointment. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> completeAppointment() async {
    final currentAppointment = appointment.value;
    if (currentAppointment == null) return;

    isLoading.value = true;
    try {
      final result = await _repository.completeAppointment(
        currentAppointment.id,
      );
      if (result != null) {
        appointment.value = result;
        Get.snackbar(
          'Success',
          'Appointment completed successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to complete appointment. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelAppointment(String? reason) async {
    final currentAppointment = appointment.value;
    if (currentAppointment == null) return;

    isLoading.value = true;
    try {
      final success = await _repository.cancelAppointment(
        currentAppointment.id,
        reason: reason,
      );
      if (success) {
        // Refresh appointment data
        await loadAppointmentDetails(currentAppointment.id.toString());
        Get.snackbar(
          'Success',
          'Appointment cancelled successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel appointment. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rescheduleAppointment(DateTime newDateTime) async {
    final currentAppointment = appointment.value;
    if (currentAppointment == null) return;

    isLoading.value = true;
    try {
      final result = await _repository.rescheduleAppointment(
        currentAppointment.id,
        newDateTime,
        durationMinutes: currentAppointment.durationMinutes,
      );
      if (result != null) {
        appointment.value = result;
        Get.snackbar(
          'Success',
          'Appointment rescheduled successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to reschedule appointment. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // lib/features/appointments/controllers/appointment_detail_controller.dart
  // Add these methods to the existing controller

  // ==================== PAYMENT ACTIONS ====================

  /// Check if payment is already confirmed
  bool get isPaymentConfirmed {
    final app = appointment.value;
    if (app == null) return false;
    if (app.payment == null) return false;
    return app.payment!.status == AppointmentPaymentStatus.confirmed;
  }

  /// Get payment status display text
  String get paymentStatusDisplay {
    final app = appointment.value;
    if (app == null) return 'No payment required';
    if (app.payment == null) return 'No payment required';
    return app.payment!.statusDisplay;
  }

  /// Get payment status color
  Color get paymentStatusColor {
    final app = appointment.value;
    if (app == null) return AppColors.onSurfaceVariant;
    if (app.payment == null) return AppColors.onSurfaceVariant;
    return app.payment!.statusColor;
  }

  /// Get payment amount display
  String get paymentAmountDisplay {
    final app = appointment.value;
    if (app == null) return '—';
    if (app.payment == null) return '—';
    return '${app.payment!.totalAmount} PKR';
  }

  Future<void> updateDoctorNotes(String notes) async {
    final currentAppointment = appointment.value;
    if (currentAppointment == null) return;

    isLoading.value = true;
    try {
      final result = await _repository.addDoctorNotes(
        currentAppointment.id,
        notes,
      );
      if (result != null) {
        appointment.value = result;
        Get.snackbar(
          'Success',
          'Notes saved successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save notes. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // void openMeetingLink(String link) async {
  //   final url = Uri.parse(link);
  //   if (await canLaunchUrl(url)) {
  //     await launchUrl(url, mode: LaunchMode.externalApplication);
  //   } else {
  //     Get.snackbar(
  //       'Error',
  //       'Could not open meeting link.',
  //       snackPosition: SnackPosition.TOP,
  //       backgroundColor: AppColors.error,
  //       colorText: Colors.white,
  //     );
  //   }
  // }

  @override
  void onClose() {
    super.onClose();
  }
}
