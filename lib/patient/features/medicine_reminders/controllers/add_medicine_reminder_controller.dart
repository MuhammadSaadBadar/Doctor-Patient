// lib/patient/features/medicine_reminders/controllers/add_medicine_reminder_controller.dart

import 'package:doctor/patient/features/medicine_reminders/models/medicine_reminder.dart';
import 'package:doctor/patient/features/medicine_reminders/repositories/medicine_reminder_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddMedicineReminderController extends GetxController {
  final MedicineReminderRepository _repository =
      Get.find<MedicineReminderRepository>();

  // State
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final isEditing = false.obs;
  final editingId = 0.obs;

  // Form Controllers
  final medicineNameController = TextEditingController();
  final dosageController = TextEditingController();

  // Form State
  final timesPerDay = 2.obs;
  final reminderTimes = <String>[].obs;
  final startDate = Rx<DateTime?>(DateTime.now());
  final endDate = Rx<DateTime?>(null);
  final isActive = true.obs;

  // Validation
  final medicineNameError = ''.obs;
  final reminderTimesError = ''.obs;
  final startDateError = ''.obs;

  // Computed
  bool get isValid {
    final nameValid = medicineNameController.text.trim().isNotEmpty;
    final timesValid = reminderTimes.isNotEmpty;
    final dateValid = startDate.value != null;
    return nameValid && timesValid && dateValid;
  }

  @override
  void onInit() {
    super.onInit();
    // Check if editing
    final args = Get.arguments;
    if (args is Map && args.containsKey('reminder')) {
      final reminder = args['reminder'] as MedicineReminder;
      _loadForEditing(reminder);
    }
  }

  @override
  void onClose() {
    medicineNameController.dispose();
    dosageController.dispose();
    super.onClose();
  }

  void _loadForEditing(MedicineReminder reminder) {
    isEditing.value = true;
    editingId.value = reminder.id;
    medicineNameController.text = reminder.medicineName;
    dosageController.text = reminder.dosage;
    timesPerDay.value = reminder.timesPerDay;
    reminderTimes.value = List.from(reminder.reminderTimes);
    startDate.value = reminder.startDate;
    endDate.value = reminder.endDate;
    isActive.value = reminder.isActive;
  }

  void validateMedicineName() {
    final name = medicineNameController.text.trim();
    if (name.isEmpty) {
      medicineNameError.value = 'Please enter a medicine name';
    } else if (name.length < 2) {
      medicineNameError.value = 'Medicine name must be at least 2 characters';
    } else {
      medicineNameError.value = '';
    }
  }

  void validateReminderTimes() {
    if (reminderTimes.isEmpty) {
      reminderTimesError.value = 'Please add at least one reminder time';
    } else {
      reminderTimesError.value = '';
    }
  }

  void validateStartDate() {
    if (startDate.value == null) {
      startDateError.value = 'Please select a start date';
    } else {
      startDateError.value = '';
    }
  }

  void incrementTimesPerDay() {
    if (timesPerDay.value < 4) {
      timesPerDay.value++;
    }
  }

  void decrementTimesPerDay() {
    if (timesPerDay.value > 1) {
      timesPerDay.value--;
    }
  }

  Future<void> pickStartDate(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final picked = await showDatePicker(
      context: context,
      initialDate: startDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // ✅ Override just the date picker's background
            datePickerTheme: DatePickerThemeData(
              backgroundColor: isDark ? cs.background : cs.surface,
              headerBackgroundColor: isDark ? cs.background : cs.surface,
              headerForegroundColor: isDark ? cs.onBackground : cs.onSurface,
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return cs.onPrimary;
                }
                return isDark ? cs.onBackground : cs.onSurface;
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return cs.primary;
                }
                return null;
              }),
              todayBorder: BorderSide(color: cs.primary, width: 1.5),
              todayForegroundColor: WidgetStatePropertyAll(cs.primary),
              weekdayStyle: TextStyle(
                color: (isDark ? cs.onBackground : cs.onSurface).withValues(
                  alpha: 0.7,
                ),
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
      startDate.value = picked;
    }
  }

  Future<void> pickEndDate(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ End date must be after the start date (or today, whichever is later)
    final today = DateTime.now();
    final start = startDate.value;
    final firstDate = start != null && start.isAfter(today) ? start : today;

    final picked = await showDatePicker(
      context: context,
      initialDate: endDate.value ?? firstDate.add(const Duration(days: 30)),
      firstDate: firstDate,
      lastDate: today.add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // ✅ Same dark-mode override as pickStartDate
            datePickerTheme: DatePickerThemeData(
              backgroundColor: isDark ? cs.background : cs.surface,
              headerBackgroundColor: isDark ? cs.background : cs.surface,
              headerForegroundColor: isDark ? cs.onBackground : cs.onSurface,
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return cs.onPrimary;
                }
                return isDark ? cs.onBackground : cs.onSurface;
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return cs.primary;
                }
                return null;
              }),
              todayBorder: BorderSide(color: cs.primary, width: 1.5),
              todayForegroundColor: WidgetStatePropertyAll(cs.primary),
              weekdayStyle: TextStyle(
                color: (isDark ? cs.onBackground : cs.onSurface).withValues(
                  alpha: 0.7,
                ),
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
      endDate.value = picked;
    }
  }

  void addReminderTime() {
    // Show time picker
    _showTimePicker();
  }

  void _showTimePicker() async {
    final time = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      final timeString = _formatTimeOfDay(time);
      if (!reminderTimes.contains(timeString)) {
        reminderTimes.add(timeString);
        validateReminderTimes();
      }
    }
  }

  void removeReminderTime(int index) {
    reminderTimes.removeAt(index);
    validateReminderTimes();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDisplayTime(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final amPm = hour >= 12 ? 'PM' : 'AM';
      return '$hour12:${minute.toString().padLeft(2, '0')} $amPm';
    } catch (_) {
      return time;
    }
  }

  Future<void> submit() async {
    // Validate all fields
    validateMedicineName();
    validateReminderTimes();
    validateStartDate();

    if (!isValid) return;

    isSubmitting.value = true;

    try {
      MedicineReminder? result;

      if (isEditing.value) {
        result = await _repository.updateReminder(
          id: editingId.value,
          medicineName: medicineNameController.text.trim(),
          dosage: dosageController.text.trim(),
          timesPerDay: timesPerDay.value,
          reminderTimes: reminderTimes,
          startDate: startDate.value!,
          endDate: endDate.value,
          isActive: isActive.value,
        );
      } else {
        result = await _repository.createReminder(
          medicineName: medicineNameController.text.trim(),
          dosage: dosageController.text.trim(),
          timesPerDay: timesPerDay.value,
          reminderTimes: reminderTimes,
          startDate: startDate.value!,
          endDate: endDate.value,
          isActive: isActive.value,
        );
      }

      if (result != null) {
        Get.back(result: result);
      } else {
        Get.snackbar(
          'Error',
          isEditing.value
              ? 'Failed to update reminder. Please try again.'
              : 'Failed to add reminder. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint('[ADD_MEDICINE] Error: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  void cancel() {
    Get.back(result: null);
  }

  String getTitle() {
    return isEditing.value ? 'Edit Reminder' : 'Add Reminder';
  }

  String getSubmitLabel() {
    return isEditing.value ? 'Update Reminder' : 'Save Reminder';
  }

  String getDisplayTime(String time) {
    return _formatDisplayTime(time);
  }
}
