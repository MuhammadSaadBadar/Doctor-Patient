// lib/patient/features/medicine_reminders/controllers/medicine_reminder_controller.dart

import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/patient/features/medicine_reminders/models/medicine_adherence.dart';
import 'package:doctor/patient/features/medicine_reminders/models/medicine_reminder.dart';
import 'package:doctor/patient/features/medicine_reminders/repositories/medicine_reminder_repository.dart';
import 'package:doctor/patient/features/medicine_reminders/models/medicine_intake_log.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MedicineReminderController extends GetxController {
  final MedicineReminderRepository _repository =
      Get.find<MedicineReminderRepository>();

  // State
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final isSubmitting = false.obs;

  // Data
  final reminders = <MedicineReminder>[].obs;

  // Pagination
  final currentPage = 1.obs;
  final hasMoreData = true.obs;
  final totalCount = 0.obs;

  // Computed getters
  bool get hasReminders => reminders.isNotEmpty;
  bool get isEmpty => !hasReminders && !isLoading.value;

  int get activeCount => reminders.where((r) => r.isActive).length;
  int get todayDoses {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return reminders
        .where(
          (r) =>
              r.isActive &&
              r.startDate.isBefore(now.add(const Duration(days: 1))),
        )
        .fold(0, (sum, r) => sum + r.timesPerDay);
  }

  double get overallAdherence {
    if (reminders.isEmpty) return 0.0;
    final totalAdherence = reminders.fold<double>(
      0.0,
      (sum, r) => sum + (r.hasAdherence ? r.adherencePercentage : 0.0),
    );
    return totalAdherence / reminders.length;
  }

  @override
  void onInit() {
    super.onInit();
    loadReminders();
  }

  Future<void> loadReminders({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
      reminders.clear();
    }

    if (!hasMoreData.value) return;

    isLoading.value = reminders.isEmpty;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await _repository.getReminders(
        page: currentPage.value,
        pageSize: 50,
      );

      if (result != null) {
        // Fetch today's intake logs to reconstruct the correct adherence state
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));
        
        final logsResult = await _repository.getIntakeLogs(
          page: 1,
          pageSize: 1000, // Fetch all logs for today
          startDate: today,
          endDate: tomorrow,
        );

        final updatedReminders = <MedicineReminder>[];
        for (var reminder in result.results) {
          int taken = 0;
          int skipped = 0;
          
          if (logsResult != null) {
            final reminderLogs = logsResult.results.where((log) => 
                log.reminderId == reminder.id &&
                log.scheduledFor.isAfter(today.subtract(const Duration(seconds: 1))) &&
                log.scheduledFor.isBefore(tomorrow)
            );
            taken = reminderLogs.where((log) => log.isTaken).length;
            skipped = reminderLogs.where((log) => log.isSkipped).length;
          }
          
          final pending = reminder.timesPerDay - (taken + skipped);
          final adherence = MedicineAdherence(
            taken: taken,
            skipped: skipped,
            pending: pending > 0 ? pending : 0,
          );
          
          updatedReminders.add(reminder.copyWith(adherence: adherence));
        }

        reminders.addAll(updatedReminders);
        totalCount.value = result.count;
        hasMoreData.value = result.hasNext;
        currentPage.value++;
        debugPrint('[MEDICINE] Loaded ${reminders.length} reminders');
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to load reminders. Please try again.';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Something went wrong. Please try again.';
      debugPrint('[MEDICINE] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadReminders(refresh: true);
  }

  void applyIntakeStatus(int reminderId, String status) {
    final index = reminders.indexWhere((reminder) => reminder.id == reminderId);
    if (index == -1) return;

    final reminder = reminders[index];
    final current =
        reminder.adherence ??
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

    reminders[index] = reminder.copyWith(adherence: updated);
    reminders.refresh();
  }

  Future<void> loadMore() async {
    if (!hasMoreData.value || isLoading.value) return;
    await loadReminders();
  }

  Future<void> toggleReminder(MedicineReminder reminder) async {
    try {
      final result = await _repository.toggleReminder(reminder.id);
      if (result != null) {
        final index = reminders.indexWhere((r) => r.id == reminder.id);
        if (index != -1) {
          reminders[index] = result;
          reminders.refresh();
        }
        _showToast(
          '${reminder.medicineName} reminder ${result.isActive ? 'activated' : 'deactivated'}',
        );
      } else {
        _showErrorToast('Failed to toggle reminder');
      }
    } catch (e) {
      _showErrorToast('Something went wrong');
      debugPrint('[MEDICINE] Error toggling: $e');
    }
  }

  Future<void> deleteReminder(MedicineReminder reminder) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text(
          'Are you sure you want to delete the reminder for "${reminder.medicineName}"? This action cannot be undone.',
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

    try {
      final success = await _repository.deleteReminder(reminder.id);
      if (success) {
        reminders.removeWhere((r) => r.id == reminder.id);
        _showToast('Reminder deleted successfully');
      } else {
        _showErrorToast('Failed to delete reminder');
      }
    } catch (e) {
      _showErrorToast('Something went wrong');
      debugPrint('[MEDICINE] Error deleting: $e');
    }
  }

  // ✅ FIXED: Navigation methods with proper route constants

  void navigateToAddReminder() {
    Get.toNamed(AppRoutes.addMedicineReminder)?.then((_) => refreshData());
  }

  void navigateToEditReminder(MedicineReminder reminder) {
    Get.toNamed(
      AppRoutes.editMedicineReminder.replaceAll(':id', '${reminder.id}'),
      arguments: {'reminder': reminder},
    )?.then((_) => refreshData());
  }

  void navigateToIntakeLogs() {
    Get.toNamed(AppRoutes.medicineIntakeLogs);
  }

  void navigateToReminderDetail(int id) {
    Get.toNamed(
      AppRoutes.medicineReminderDetail.replaceAll(':id', '$id'),
      arguments: {'reminderId': id},
    );
  }

  void navigateBack() {
    Get.back();
  }

  void navigateToHome() {
    Get.offAllNamed('/dashboard');
  }

  void navigateToHealth() {
    Get.toNamed('/health');
  }

  void navigateToAppointments() {
    Get.toNamed('/appointments');
  }

  void navigateToAIAssistant() {
    Get.toNamed('/ai-assistant');
  }

  void navigateToProfile() {
    Get.toNamed('/profile');
  }

  // Helpers
  void _showToast(String message) {
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

  void _showErrorToast(String message) {
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
