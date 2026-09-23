// lib/patient/features/medicine_reminders/controllers/medicine_reminder_detail_controller.dart

import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/patient/features/medicine_reminders/controllers/medicine_reminder_controller.dart';
import 'package:doctor/patient/features/medicine_reminders/models/medicine_adherence.dart';
import 'package:doctor/patient/features/medicine_reminders/models/medicine_reminder.dart';
import 'package:doctor/patient/features/medicine_reminders/repositories/medicine_reminder_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MedicineReminderDetailController extends GetxController {
  final MedicineReminderRepository _repository =
      Get.find<MedicineReminderRepository>();

  // State
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final isDeleting = false.obs;

  // Data
  final reminder = Rx<MedicineReminder?>(null);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['reminderId'] != null) {
      loadReminder(args['reminderId']);
    } else if (args != null && args['reminder'] != null) {
      reminder.value = args['reminder'] as MedicineReminder;
      _syncAdherenceFromList(args['reminder'].id);
    }
  }

  Future<void> loadReminder(int id) async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await _repository.getReminderById(id);
      if (result != null) {
        // Fetch today's intake logs to reconstruct the correct adherence state
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));
        
        final logsResult = await _repository.getIntakeLogs(
          page: 1,
          pageSize: 1000, 
          reminderId: id,
          startDate: today,
          endDate: tomorrow,
        );

        int taken = 0;
        int skipped = 0;
        
        if (logsResult != null) {
          final reminderLogs = logsResult.results.where((log) => 
              log.reminderId == id &&
              log.scheduledFor.isAfter(today.subtract(const Duration(seconds: 1))) &&
              log.scheduledFor.isBefore(tomorrow)
          );
          taken = reminderLogs.where((log) => log.isTaken).length;
          skipped = reminderLogs.where((log) => log.isSkipped).length;
        }
        
        final pending = result.timesPerDay - (taken + skipped);
        final adherence = MedicineAdherence(
          taken: taken,
          skipped: skipped,
          pending: pending > 0 ? pending : 0,
        );
          
        reminder.value = result.copyWith(adherence: adherence);
        
        // Sync the newly fetched adherence back to the list controller
        if (Get.isRegistered<MedicineReminderController>()) {
          final listController = Get.find<MedicineReminderController>();
          final index = listController.reminders.indexWhere((r) => r.id == id);
          if (index != -1) {
             listController.reminders[index] = listController.reminders[index].copyWith(adherence: adherence);
             listController.reminders.refresh();
          }
        }
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to load reminder details.';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Something went wrong. Please try again.';
      debugPrint('[MEDICINE_DETAIL] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _syncAdherenceFromList(int reminderId) {
    if (!Get.isRegistered<MedicineReminderController>()) return;
    final listController = Get.find<MedicineReminderController>();
    final listReminder = listController.reminders.firstWhereOrNull(
      (r) => r.id == reminderId,
    );
    if (listReminder?.adherence != null) {
      final current = reminder.value;
      if (current != null) {
        reminder.value = current.copyWith(adherence: listReminder!.adherence);
      }
    }
  }

  Future<void> deleteReminder() async {
    final r = reminder.value;
    if (r == null) return;

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text(
          'Are you sure you want to delete the reminder for "${r.medicineName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    isDeleting.value = true;

    try {
      final success = await _repository.deleteReminder(r.id);
      if (success) {
        Get.snackbar(
          'Success',
          'Reminder deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF226B3F),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 30,
        );
        Get.back(result: true); // Return true to indicate deletion
      } else {
        _showErrorSnackbar('Failed to delete reminder');
      }
    } catch (e) {
      _showErrorSnackbar('Something went wrong');
      debugPrint('[MEDICINE_DETAIL] Error deleting: $e');
    } finally {
      isDeleting.value = false;
    }
  }

  void applyIntakeStatus(int reminderId, String status) {
    final currentReminder = reminder.value;
    if (currentReminder == null) return;
    if (currentReminder.id != reminderId) return;

    final current =
        currentReminder.adherence ??
        MedicineAdherence(taken: 0, skipped: 0, pending: 0);
    final wasPending = current.pending > 0;
    final updated = status == 'taken'
        ? current.copyWith(
            taken: current.taken + 1,
            pending: wasPending ? current.pending - 1 : current.pending,
          )
        : current.copyWith(
            skipped: current.skipped + 1,
            pending: wasPending ? current.pending - 1 : current.pending,
          );

    reminder.value = currentReminder.copyWith(adherence: updated);
  }

  void toggleReminder() async {
    final r = reminder.value;
    if (r == null) return;

    try {
      final result = await _repository.toggleReminder(r.id);
      if (result != null) {
        reminder.value = result;
        _showSnackbar(
          '${r.medicineName} reminder ${result.isActive ? 'activated' : 'deactivated'}',
        );
      } else {
        _showErrorSnackbar('Failed to toggle reminder');
      }
    } catch (e) {
      _showErrorSnackbar('Something went wrong');
      debugPrint('[MEDICINE_DETAIL] Error toggling: $e');
    }
  }

  void navigateToEdit() {
    final r = reminder.value;
    if (r != null) {
      Get.toNamed(
        '/medicine-reminders/edit/${r.id}',
        arguments: {'reminder': r},
      )?.then((_) => loadReminder(r.id));
    }
  }

  void navigateToIntakeLogs() {
    final r = reminder.value;
    if (r != null) {
      Get.toNamed(
        AppRoutes.medicineIntakeLogs,
        arguments: {'reminderId': r.id},
      );
    }
  }

  void navigateBack() {
    Get.back();
  }

  void _showSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF226B3F),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 30,
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 30,
    );
  }
}
