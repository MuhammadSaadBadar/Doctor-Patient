// lib/features/patient/controllers/create_edit_medicine_reminder_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor/core/network/api_exceptions.dart';
import 'package:doctor/core/utils/validation_utils.dart';
import 'package:doctor/features/patient/models/medicine_reminder.dart';
import 'package:doctor/features/patient/repositories/medicine_reminder_repository.dart';

class CreateEditMedicineReminderController extends GetxController {
  final MedicineReminderRepository _repository = MedicineReminderRepository();

  // Arguments
  final String? reminderId = Get.arguments?['reminderId'] as String?;
  int? patientId = Get.arguments?['patientId'] as int?;
  final String patientName = Get.arguments?['patientName'] as String? ?? '';

  // Form controllers
  final medicineNameController = TextEditingController();
  final dosageController = TextEditingController();

  // Form state
  final timesPerDay = 1.obs;
  final reminderTimes = <String>[].obs;
  final startDate = DateTime.now().obs;
  final endDate = Rx<DateTime?>(null);
  final isActive = true.obs;
  final isSubmitting = false.obs;

  // Error state
  final medicineNameError = ''.obs;
  final timesPerDayError = ''.obs;
  final reminderTimesError = ''.obs;
  final patientIdError = ''.obs;
  final dosageError = ''.obs;
  final startDateError = ''.obs;
  final endDateError = ''.obs;
  final isActiveError = ''.obs;

  // Editing state
  final isEditing = false.obs;
  MedicineReminder? _originalReminder;

  @override
  void onInit() {
    super.onInit();
    _initializeForm();
  }

  void _initializeForm() {
    isEditing.value = reminderId != null;

    if (isEditing.value) {
      // Load existing reminder data
      _loadReminderData();
    } else {
      // Initialize with default times
      _initializeDefaultTimes();
    }
  }

  void _initializeDefaultTimes() {
    // Default times: 8:00 AM and 8:00 PM
    reminderTimes.assignAll(['08:00', '20:00']);
    // Adjust based on times per day
    _adjustTimesForCount();
  }

  void _adjustTimesForCount() {
    while (reminderTimes.length > timesPerDay.value) {
      reminderTimes.removeLast();
    }
    while (reminderTimes.length < timesPerDay.value) {
      // Add evenly spaced times
      final hour = 8 + (reminderTimes.length * 6);
      final displayHour = hour > 23 ? hour - 24 : hour;
      reminderTimes.add('${displayHour.toString().padLeft(2, '0')}:00');
    }
  }

  Future<void> _loadReminderData() async {
    if (reminderId == null) return;

    try {
      final reminder = await _repository.getMedicineReminder(reminderId!);
      if (reminder != null) {
        _originalReminder = reminder;
        medicineNameController.text = reminder.medicineName;
        dosageController.text = reminder.dosage;
        timesPerDay.value = reminder.timesPerDay;
        reminderTimes.assignAll(reminder.reminderTimes);
        startDate.value = reminder.startDate;
        endDate.value = reminder.endDate;
        isActive.value = reminder.isActive;
        // Ensure patientId is set from loaded reminder data as fallback
        if (patientId == null || patientId == 0) {
          patientId = reminder.patientId;
        }
      }
    } catch (e) {
      debugPrint('[CREATE_MEDICINE_REMINDER] Error loading reminder: $e');
    }
  }

  void updateReminderTimes() {
    // Clear errors
    reminderTimesError.value = '';

    // Adjust times based on count
    if (timesPerDay.value > reminderTimes.length) {
      final currentCount = reminderTimes.length;
      for (int i = 0; i < timesPerDay.value - currentCount; i++) {
        final hour = 8 + ((currentCount + i) * 6);
        final displayHour = hour > 23 ? hour - 24 : hour;
        reminderTimes.add('${displayHour.toString().padLeft(2, '0')}:00');
      }
    } else if (timesPerDay.value < reminderTimes.length) {
      reminderTimes.removeRange(timesPerDay.value, reminderTimes.length);
    }
  }

  void addReminderTime() {
    if (reminderTimes.length >= 6) {
      Get.snackbar(
        'Max Times',
        'Maximum 6 reminder times allowed per day',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange[800],
      );
      return;
    }

    // Add a new time (default to 8:00 AM if no times exist)
    final hour = 8 + (reminderTimes.length * 4);
    final displayHour = hour > 23 ? hour - 24 : hour;
    reminderTimes.add('${displayHour.toString().padLeft(2, '0')}:00');
    reminderTimesError.value = '';
  }

  void removeReminderTime(int index) {
    if (reminderTimes.length <= 1) {
      Get.snackbar(
        'Minimum Times',
        'At least one reminder time is required',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange[800],
      );
      return;
    }
    reminderTimes.removeAt(index);
    reminderTimesError.value = '';
  }

  void updateReminderTime(int index, String newTime) {
    reminderTimes[index] = newTime;
    reminderTimesError.value = '';
  }

  void clearEndDate() {
    endDate.value = null;
  }

  bool validateForm() {
    bool isValid = true;

    // Validate medicine name
    if (medicineNameController.text.trim().isEmpty) {
      medicineNameError.value = 'Medicine name is required';
      isValid = false;
    } else {
      medicineNameError.value = '';
    }

    // Validate times per day
    if (timesPerDay.value < 1) {
      timesPerDayError.value = 'Times per day must be at least 1';
      isValid = false;
    } else {
      timesPerDayError.value = '';
    }

    // Validate reminder times
    if (reminderTimes.isEmpty) {
      reminderTimesError.value = 'At least one reminder time is required';
      isValid = false;
    } else {
      // Check for duplicate times
      final uniqueTimes = reminderTimes.toSet().toList();
      if (uniqueTimes.length != reminderTimes.length) {
        reminderTimesError.value = 'Duplicate reminder times are not allowed';
        isValid = false;
      } else {
        reminderTimesError.value = '';
      }
    }

    // Validate start date
    if (endDate.value != null && endDate.value!.isBefore(startDate.value)) {
      Get.snackbar(
        'Invalid Dates',
        'End date must be after start date',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
      );
      isValid = false;
    }

    return isValid;
  }

  Future<void> submit() async {
    if (!validateForm()) return;

    isSubmitting.value = true;

    try {
      final data = {
        'patient_id': patientId,
        'medicine_name': medicineNameController.text.trim(),
        'dosage': dosageController.text.trim(),
        'times_per_day': timesPerDay.value,
        'reminder_times': reminderTimes.toList(),
        'start_date': startDate.value.toIso8601String().split('T')[0],
        'is_active': isActive.value,
        if (endDate.value != null)
          'end_date': endDate.value!.toIso8601String().split('T')[0],
      };

      MedicineReminder? result;

      if (isEditing.value && reminderId != null) {
        result = await _repository.updateMedicineReminder(reminderId!, data);
      } else {
        result = await _repository.createMedicineReminder(data);
      }

      if (result != null) {
        Get.back(result: true);
        Get.snackbar(
          'Success',
          isEditing.value
              ? 'Medicine reminder updated successfully'
              : 'Medicine reminder created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green[800],
        );
      } else {
        throw Exception('Failed to save reminder');
      }
    } catch (e) {
      if (e is ApiException && e.fieldErrors != null) {
        handleApiFieldErrors(
          e.fieldErrors!,
          {
            'patient_id': patientIdError,
            'medicine_name': medicineNameError,
            'dosage': dosageError,
            'times_per_day': timesPerDayError,
            'reminder_times': reminderTimesError,
            'start_date': startDateError,
            'end_date': endDateError,
            'is_active': isActiveError,
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
          'Failed to save medicine reminder',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[800],
        );
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    medicineNameController.dispose();
    dosageController.dispose();
    super.onClose();
  }
}
