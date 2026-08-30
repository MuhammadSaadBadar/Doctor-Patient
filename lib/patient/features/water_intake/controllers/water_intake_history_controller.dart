// lib/patient/features/water_intake/controllers/water_intake_history_controller.dart

import 'package:doctor/patient/features/water_intake/models/water_intake_entry.dart';
import 'package:doctor/patient/features/water_intake/models/water_intake_history.dart';
import 'package:doctor/patient/features/water_intake/repositories/water_intake_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WaterIntakeHistoryController extends GetxController {
  final WaterIntakeRepository _repository = WaterIntakeRepository();

  // State
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Data
  final history = Rx<WaterIntakeHistory?>(null);
  final entries = <WaterIntakeEntry>[].obs;

  // Pagination
  final currentPage = 1.obs;
  final hasMoreData = true.obs;

  // Computed getters
  bool get hasEntries => entries.isNotEmpty;
  bool get isEmpty => !hasEntries && !isLoading.value;
  Map<String, List<WaterIntakeEntry>> get groupedEntries =>
      _groupByDate(entries);
  List<String> get sortedDateKeys => history.value?.sortedDateKeys ?? [];

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
      entries.clear();
    }

    if (!hasMoreData.value) return;

    isLoading.value = entries.isEmpty;
    isLoadingMore.value = entries.isNotEmpty;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await _repository.getHistory(
        page: currentPage.value,
        pageSize: 20,
      );

      if (result != null) {
        entries.addAll(result.entries);
        history.value = result;
        hasMoreData.value = result.hasNext;
        currentPage.value++;
        debugPrint('[WATER_INTAKE_HISTORY] Loaded ${entries.length} entries');
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to load history. Please try again.';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Something went wrong. Please try again.';
      debugPrint('[WATER_INTAKE_HISTORY] Error: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadHistory(refresh: true);
  }

  Future<void> loadMore() async {
    if (!hasMoreData.value || isLoadingMore.value) return;
    await loadHistory();
  }

  // Helper methods
  Map<String, List<WaterIntakeEntry>> _groupByDate(
    List<WaterIntakeEntry> entries,
  ) {
    final Map<String, List<WaterIntakeEntry>> groups = {};

    for (final entry in entries) {
      final dateKey = entry.logDate.toIso8601String().split('T')[0];
      if (!groups.containsKey(dateKey)) {
        groups[dateKey] = [];
      }
      groups[dateKey]!.add(entry);
    }

    // Sort each group by time (newest first)
    for (final key in groups.keys) {
      groups[key]!.sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    }

    return groups;
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

  String formatTime(DateTime time) {
    final localTime = time.toLocal();
    final hour = localTime.hour > 12
        ? localTime.hour - 12
        : (localTime.hour == 0 ? 12 : localTime.hour);
    final minute = localTime.minute.toString().padLeft(2, '0');
    final amPm = localTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $amPm';
  }
}
