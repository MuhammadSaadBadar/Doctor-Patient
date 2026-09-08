// lib/features/patient/controllers/medicine_reminders_controller.dart

import 'package:doctor/core/services/storage_service.dart';
import 'package:doctor/doctor/features/patient/models/doc_medicine_reminder.dart';
import 'package:doctor/doctor/features/patient/repositories/doc_medicine_reminder_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorMedicineRemindersController extends GetxController {
  final DoctorMedicineReminderRepository _repository =
      DoctorMedicineReminderRepository();
  final StorageService _storage = Get.find<StorageService>();

  // State
  final reminders = <MedicineReminder>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final hasMoreData = true.obs;

  // Filter state
  final showActiveOnly = false.obs;

  // Patient ID from arguments
  int? _patientId;
  String? _patientName;

  // Pagination
  int _currentPage = 1;
  static const int _pageSize = 20;

  // Filtered reminders
  List<MedicineReminder> get filteredReminders {
    final scopedReminders = reminders
        .where((reminder) => reminder.patientId == _patientId)
        .toList();
    if (!showActiveOnly.value) return scopedReminders;
    return scopedReminders.where((reminder) => reminder.isActive).toList();
  }

  // Stats
  int get totalReminders => reminders.length;
  int get activeReminders => reminders.where((r) => r.isActive).length;
  int get inactiveReminders => reminders.where((r) => !r.isActive).length;
  int get dueTodayCount => reminders.where((r) => r.isDueToday).length;

  @override
  void onInit() {
    super.onInit();
    _loadArguments();
    _loadMedicineReminders();
  }

  void _loadArguments() {
    final args = Get.arguments;
    if (args is Map) {
      _patientId = args['patientId'] as int?;
      _patientName = args['patientName'] as String?;
    }
    debugPrint('[MEDICINE_REMINDERS] Patient ID: $_patientId');
  }

  Future<void> _loadMedicineReminders({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      reminders.clear();
      hasMoreData.value = true;
    }

    if (!hasMoreData.value) return;

    if (_patientId == null || _patientId == 0) {
      isLoading.value = false;
      hasError.value = true;
      errorMessage.value = 'A patient must be selected to view reminders.';
      return;
    }

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await _repository.getMedicineReminders(
        patientId: _patientId!,
        page: _currentPage,
        pageSize: _pageSize,
      );

      final scopedReminders = result.reminders
          .where((reminder) => reminder.patientId == _patientId)
          .toList();

      if (refresh) {
        reminders.value = scopedReminders;
      } else {
        reminders.addAll(scopedReminders);
      }

      hasMoreData.value = result.hasNext;
      _currentPage++;

      debugPrint('[MEDICINE_REMINDERS] Loaded ${reminders.length} reminders');
    } catch (e) {
      hasError.value = true;
      errorMessage.value =
          'Failed to load medicine reminders. Please try again.';
      debugPrint('[MEDICINE_REMINDERS] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await _loadMedicineReminders(refresh: true);
  }

  Future<void> loadMore() async {
    if (!isLoading.value && hasMoreData.value) {
      await _loadMedicineReminders();
    }
  }

  void toggleFilter() {
    showActiveOnly.value = !showActiveOnly.value;
  }

  Future<void> toggleReminderStatus(MedicineReminder reminder) async {
    try {
      final updated = await _repository.toggleMedicineReminder(
        reminder.id,
        !reminder.isActive,
      );

      if (updated != null) {
        final index = reminders.indexWhere((r) => r.id == reminder.id);
        if (index != -1) {
          reminders[index] = updated;
          reminders.refresh();
        }
        Get.snackbar(
          'Success',
          updated.isActive ? 'Reminder activated' : 'Reminder deactivated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green[800],
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update reminder status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
      );
      debugPrint('[MEDICINE_REMINDERS] Error toggling status: $e');
    }
  }

  Future<void> deleteReminder(MedicineReminder reminder) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text(
          'Are you sure you want to delete "${reminder.medicineName}"?',
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
      final success = await _repository.deleteMedicineReminder(reminder.id);
      if (success) {
        reminders.removeWhere((r) => r.id == reminder.id);
        Get.snackbar(
          'Success',
          'Reminder deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green[800],
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete reminder',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
      );
      debugPrint('[MEDICINE_REMINDERS] Error deleting: $e');
    }
  }

  void navigateToCreateReminder() {
    Get.toNamed(
      AppRoutes.createMedicineReminder,
      arguments: {'patientId': _patientId, 'patientName': _patientName},
    )?.then((_) => refreshData());
  }

  void navigateToEditReminder(MedicineReminder reminder) {
    Get.toNamed(
      AppRoutes.editMedicineReminder,
      arguments: {
        'reminderId': reminder.id,
        'patientId': _patientId,
        'patientName': _patientName,
      },
    )?.then((_) => refreshData());
  }

  // Adherence stats
  Future<Map<String, int>> getAdherenceStats() async {
    try {
      final logs = await _repository.getIntakeLogs(
        patientId: _patientId,
        pageSize: 50,
      );

      final taken = logs.where((l) => l.status == 'taken').length;
      final skipped = logs.where((l) => l.status == 'skipped').length;
      final pending = logs.where((l) => l.status == 'pending').length;

      return {'taken': taken, 'skipped': skipped, 'pending': pending};
    } catch (e) {
      debugPrint('[MEDICINE_REMINDERS] Error getting adherence stats: $e');
      return {'taken': 0, 'skipped': 0, 'pending': 0};
    }
  }
}

// Add these routes to AppRoutes
class AppRoutes {
  // ... existing routes ...
  static const String medicineReminders = '/medicine-reminders';
  static const String createMedicineReminder = '/create-medicine-reminder';
  static const String editMedicineReminder = '/edit-medicine-reminder';
}
