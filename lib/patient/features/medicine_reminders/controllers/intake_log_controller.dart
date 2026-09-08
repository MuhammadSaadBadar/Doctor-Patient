// lib/patient/features/medicine_reminders/controllers/intake_log_controller.dart

import 'package:doctor/patient/features/medicine_reminders/controllers/medicine_reminder_controller.dart';
import 'package:doctor/patient/features/medicine_reminders/controllers/medicine_reminder_detail_controller.dart';
import 'package:doctor/patient/features/medicine_reminders/models/intake_log_summary.dart';
import 'package:doctor/patient/features/medicine_reminders/models/medicine_intake_log.dart';
import 'package:doctor/patient/features/medicine_reminders/models/paginated_intake_log_list.dart';
import 'package:doctor/patient/features/medicine_reminders/repositories/medicine_reminder_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IntakeLogController extends GetxController {
  final MedicineReminderRepository _repository =
      Get.find<MedicineReminderRepository>();

  // View state
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final viewType = 'list'.obs; // 'list' or 'calendar'
  final selectedDateRange = 'today'.obs; // 'today', 'week', 'month', 'custom'
  final selectedReminderId = Rx<int?>(null); // null = all reminders

  // Data
  final logs = <MedicineIntakeLog>[].obs;
  final filteredLogs = <MedicineIntakeLog>[].obs;
  final paginatedData = Rx<PaginatedIntakeLogList?>(null);

  // Pagination
  final currentPage = 1.obs;
  final hasMoreData = true.obs;
  final totalCount = 0.obs;

  // Summary
  final summary = Rx<IntakeLogSummary?>(null);

  // Computed getters
  bool get hasLogs => logs.isNotEmpty;
  bool get isEmpty => !hasLogs && !isLoading.value;

  int get takenCount => summary.value?.taken ?? 0;
  int get skippedCount => summary.value?.skipped ?? 0;
  int get pendingCount => summary.value?.pending ?? 0;
  double get adherenceRate => summary.value?.adherenceRate ?? 0.0;

  @override
  void onInit() {
    super.onInit();

    // Check for reminderId argument (from detail screen)
    final args = Get.arguments;
    if (args != null && args['reminderId'] != null) {
      selectedReminderId.value = args['reminderId'] as int;
    }

    loadLogs();
  }

  Future<void> loadLogs({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
      logs.clear();
    }

    if (!hasMoreData.value) return;

    isLoading.value = logs.isEmpty;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await _repository.getIntakeLogs(
        page: currentPage.value,
        pageSize: 50,
      );

      if (result != null) {
        logs.addAll(result.results);
        paginatedData.value = result;
        hasMoreData.value = result.hasNext;
        totalCount.value = result.count;
        currentPage.value++;
        _applyFilters();
        _updateSummary();
        debugPrint('[INTAKE_LOG] Loaded ${logs.length} logs');
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to load intake logs.';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Something went wrong.';
      debugPrint('[INTAKE_LOG] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadLogs(refresh: true);
  }

  Future<void> loadMore() async {
    if (!hasMoreData.value || isLoading.value) return;
    await loadLogs();
  }

  void _applyFilters() {
    // Apply date filter based on selected range
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime? startDate;
    DateTime? endDate;

    switch (selectedDateRange.value) {
      case 'today':
        startDate = today;
        endDate = today.add(const Duration(days: 1));
        break;
      case 'week':
        final weekStart = today.subtract(Duration(days: now.weekday - 1));
        startDate = weekStart;
        endDate = weekStart.add(const Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(today.year, today.month, 1);
        endDate = DateTime(today.year, today.month + 1, 1);
        break;
      default:
        startDate = null;
        endDate = null;
    }

    filteredLogs.value = logs.where((log) {
      final logDate = DateTime(
        log.scheduledFor.year,
        log.scheduledFor.month,
        log.scheduledFor.day,
      );
      if (startDate != null && logDate.isBefore(startDate)) return false;
      if (endDate != null && logDate.isAfter(endDate)) return false;
      // Filter by reminder if selected
      if (selectedReminderId.value != null &&
          log.reminderId != selectedReminderId.value) {
        return false;
      }
      return true;
    }).toList();

    // Sort by date (newest first)
    filteredLogs.sort((a, b) => b.scheduledFor.compareTo(a.scheduledFor));
    _updateSummary();
  }

  void _updateSummary() {
    summary.value = IntakeLogSummary.fromLogs(filteredLogs);
  }

  void setViewType(String type) {
    viewType.value = type;
  }

  void setDateRange(String range) {
    selectedDateRange.value = range;
    _applyFilters();
  }

  void setReminderFilter(int? reminderId) {
    selectedReminderId.value = reminderId;
    _applyFilters();
  }

  // Group logs by date
  Map<String, List<MedicineIntakeLog>> get groupedLogs {
    final groups = <String, List<MedicineIntakeLog>>{};

    for (final log in filteredLogs) {
      final dateKey = log.scheduledFor.toIso8601String().split('T')[0];
      if (!groups.containsKey(dateKey)) {
        groups[dateKey] = [];
      }
      groups[dateKey]!.add(log);
    }

    // Sort each group by time
    for (final key in groups.keys) {
      groups[key]!.sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));
    }

    return groups;
  }

  List<String> get sortedDateKeys {
    final keys = groupedLogs.keys.toList();
    keys.sort((a, b) => b.compareTo(a));
    return keys;
  }

  String formatDate(String dateKey) {
    final date = DateTime.tryParse(dateKey);
    if (date == null) return dateKey;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today';
    }
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }

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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  int getLogsForDateCount(String dateKey) {
    return groupedLogs[dateKey]?.length ?? 0;
  }

  int getTakenForDate(String dateKey) {
    final logsForDate = groupedLogs[dateKey] ?? [];
    return logsForDate.where((log) => log.isTaken).length;
  }

  String formatTime(DateTime time) {
    final hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final amPm = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $amPm';
  }

  void navigateBack() {
    Get.back();
  }

  // Intake logging
  final isLoggingIntake = false.obs;

  Future<void> logIntake({
    required int reminderId,
    required String status,
    DateTime? scheduledFor,
  }) async {
    if (isLoggingIntake.value) return;

    isLoggingIntake.value = true;

    try {
      final result = await _repository.logIntake(
        reminderId: reminderId,
        status: status,
        scheduledFor: scheduledFor,
      );

      if (result != null) {
        // Refresh logs to show the updated intake
        await refreshData();

        // Update the reminder list adherence for the specific reminder only.
        // Do NOT call refreshData() before applyIntakeStatus — that would
        // wipe all locally-tracked adherence and cause percentages to
        // disappear from other medicine cards.
        if (Get.isRegistered<MedicineReminderController>()) {
          final reminderController = Get.find<MedicineReminderController>();
          reminderController.applyIntakeStatus(reminderId, status);
        }

        // Update the detail screen if it is showing the same reminder
        if (Get.isRegistered<MedicineReminderDetailController>()) {
          final detailController =
              Get.find<MedicineReminderDetailController>();
          detailController.applyIntakeStatus(reminderId, status);
        }

        Get.snackbar(
          'Success',
          status == 'taken'
              ? 'Medicine marked as taken'
              : 'Medicine marked as skipped',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF226B3F),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 30,
        );
      } else {
        _showErrorSnackbar('Failed to log intake. Please try again.');
      }
    } catch (e) {
      _showErrorSnackbar('Something went wrong. Please try again.');
      debugPrint('[INTAKE_LOG] Error logging intake: $e');
    } finally {
      isLoggingIntake.value = false;
    }
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
