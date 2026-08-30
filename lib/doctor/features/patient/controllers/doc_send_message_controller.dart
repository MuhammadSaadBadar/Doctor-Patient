// lib/features/patient/controllers/send_message_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor/core/network/api_exceptions.dart';
import 'package:doctor/core/utils/validation_utils.dart';
import 'package:doctor/doctor/features/patient/models/doc_patient.dart';
import 'package:doctor/doctor/features/patient/models/doc_send_message.dart';
import 'package:doctor/doctor/features/patient/repositories/doc_send_message_repository.dart';
import 'package:doctor/doctor/features/patient/repositories/doc_patient_repository.dart';

class DoctorSendMessageController extends GetxController {
  final DoctorSendMessageRepository _repository = DoctorSendMessageRepository();
  final DoctorPatientRepository _patientRepository = DoctorPatientRepository();

  // Arguments
  final Patient? patient = Get.arguments?['patient'] as Patient?;
  final int? patientId = Get.arguments?['patientId'] as int?;
  final String? patientNameFromArgs = Get.arguments?['patientName'] as String?;

  // Form controllers
  final subjectController = TextEditingController();
  final messageController = TextEditingController();

  // Form state
  final isUrgent = false.obs;
  final isSubmitting = false.obs;
  final isLoadingPatient = false.obs;

  // Error state
  final subjectError = ''.obs;
  final messageError = ''.obs;
  final patientIdError = ''.obs;
  final isUrgentError = ''.obs;

  // Character counts
  final subjectCount = 0.obs;
  final messageCount = 0.obs;

  // Max lengths
  static const int maxSubjectLength = 200;
  static const int maxMessageLength = 1000;

  // Computed
  String get patientName {
    if (patient != null && patient!.name.isNotEmpty) {
      return patient!.name;
    }
    if (patientNameFromArgs != null && patientNameFromArgs!.isNotEmpty) {
      return patientNameFromArgs!;
    }
    return 'Unknown Patient';
  }

  String get patientInitials {
    if (patient != null && patient!.name.isNotEmpty) {
      final parts = patient!.name.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return patient!.name.substring(0, 1).toUpperCase();
    }
    if (patientNameFromArgs != null && patientNameFromArgs!.isNotEmpty) {
      final parts = patientNameFromArgs!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return patientNameFromArgs!.substring(0, 1).toUpperCase();
    }
    return 'PT';
  }

  String get patientDisplayId {
    if (patient != null && patient!.patientId.isNotEmpty) {
      return patient!.patientId;
    }
    return 'N/A';
  }

  String get patientWeek {
    if (patient != null && patient!.week != 'N/A') {
      return patient!.week.replaceAll('Week ', '');
    }
    return 'N/A';
  }

  String? get patientEdd {
    if (patient != null && patient!.edd != 'N/A') {
      return patient!.edd;
    }
    return 'N/A';
  }

  @override
  void onInit() {
    super.onInit();
    _setupListeners();
    _validateArguments();
    _loadPatientIfNeeded();
  }

  void _setupListeners() {
    subjectController.addListener(() {
      subjectCount.value = subjectController.text.length;
    });

    messageController.addListener(() {
      messageCount.value = messageController.text.length;
    });
  }

  void _validateArguments() {
    if (patient == null && patientId == null) {
      Get.snackbar(
        'Error',
        'Patient information is missing',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
      );
      Get.back();
    }
  }

  Future<void> _loadPatientIfNeeded() async {
    // If we already have patient object or no patientId, skip
    if (patient != null || patientId == null) return;

    isLoadingPatient.value = true;
    try {
      final patientData = await _patientRepository.getPatientById(patientId!);
      // We can't assign to final patient, but we have the name from args as fallback
      // The patientName getter will use patientNameFromArgs
      debugPrint('[SEND_MESSAGE] Loaded patient: ${patientData?.fullName}');
    } catch (e) {
      debugPrint('[SEND_MESSAGE] Error loading patient: $e');
    } finally {
      isLoadingPatient.value = false;
    }
  }

  bool validateForm() {
    bool isValid = true;

    // Validate subject
    if (subjectController.text.trim().isEmpty) {
      subjectError.value = 'Subject is required';
      isValid = false;
    } else if (subjectController.text.length > maxSubjectLength) {
      subjectError.value = 'Subject cannot exceed $maxSubjectLength characters';
      isValid = false;
    } else {
      subjectError.value = '';
    }

    // Validate message
    if (messageController.text.trim().isEmpty) {
      messageError.value = 'Message body is required';
      isValid = false;
    } else if (messageController.text.length > maxMessageLength) {
      messageError.value = 'Message cannot exceed $maxMessageLength characters';
      isValid = false;
    } else {
      messageError.value = '';
    }

    return isValid;
  }

  Future<void> sendMessage() async {
    if (!validateForm()) return;

    isSubmitting.value = true;

    try {
      // Use patientId from arguments or parse from patient.id
      final int id;
      if (patientId != null) {
        id = patientId!;
      } else if (patient != null && patient!.id.isNotEmpty) {
        id = int.tryParse(patient!.id) ?? 0;
      } else {
        throw Exception('Patient ID is required');
      }

      final request = SendMessageRequest(
        patientId: id,
        title: subjectController.text.trim(),
        body: messageController.text.trim(),
        isUrgent: isUrgent.value,
      );

      final response = await _repository.sendMessageToPatient(request);

      if (response != null) {
        Get.back(result: true);
        Get.snackbar(
          'Success',
          'Message sent successfully to $patientName',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green[800],
          duration: const Duration(seconds: 3),
        );
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      if (e is ApiException && e.fieldErrors != null) {
        handleApiFieldErrors(
          e.fieldErrors!,
          {
            'patient_id': patientIdError,
            'title': subjectError,
            'body': messageError,
            'is_urgent': isUrgentError,
          },
          fallbackSnackbar: (field, message) {
            Get.snackbar(
              'Error',
              message,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.withOpacity(0.1),
              colorText: Colors.red[800],
            );
          },
        );
      } else {
        Get.snackbar(
          'Error',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[800],
        );
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  void cancel() {
    Get.back();
  }

  @override
  void onClose() {
    subjectController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
