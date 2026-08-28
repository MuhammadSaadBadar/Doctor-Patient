// lib/features/patient/controllers/blood_pressure_history_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor/features/patient/repositories/patient_repository.dart';

class BloodPressureHistoryController extends GetxController {
  final PatientRepository _repository = Get.find<PatientRepository>();

  // State variables
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final readings = <Map<String, dynamic>>[].obs;
  final groupedReadings = <String, List<Map<String, dynamic>>>{}.obs;

  // Patient ID — resolved from route arguments
  int? _patientId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      _patientId = args['patientId'] as int?;
      loadBloodPressureHistory();
    }
  }

  Future<void> loadBloodPressureHistory() async {
    if (_patientId == null) {
      hasError.value = true;
      errorMessage.value = 'Patient ID not provided';
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      debugPrint(
        '[BP_HISTORY] Loading blood pressure history for patient $_patientId',
      );

      // Fetch all blood pressure readings (no pagination limit, get all)
      final bpReadings = await _repository.getBloodPressureReadings(
        _patientId!,
        pageSize: 100,
      );

      if (bpReadings.isNotEmpty) {
        // Sort by recorded_at descending (most recent first)
        bpReadings.sort((a, b) {
          final dateA = DateTime.tryParse(a['recorded_at']?.toString() ?? '');
          final dateB = DateTime.tryParse(b['recorded_at']?.toString() ?? '');
          if (dateA == null || dateB == null) return 0;
          return dateB.compareTo(dateA);
        });

        readings.value = bpReadings;
        groupReadingsByDate(bpReadings);
      } else {
        readings.value = [];
        groupedReadings.value = {};
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value =
          'Failed to load blood pressure history. Please try again.';
      debugPrint('[BP_HISTORY] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void groupReadingsByDate(List<Map<String, dynamic>> readings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final groups = <String, List<Map<String, dynamic>>>{};

    for (final reading in readings) {
      final recordedAt = DateTime.tryParse(
        reading['recorded_at']?.toString() ?? '',
      );
      if (recordedAt == null) continue;

      final date = DateTime(recordedAt.year, recordedAt.month, recordedAt.day);
      String groupKey;

      if (date == today) {
        groupKey = 'Today';
      } else if (date == yesterday) {
        groupKey = 'Yesterday';
      } else {
        // Group by week for older readings
        final weekStart = date.subtract(Duration(days: date.weekday - 1));
        groupKey = 'Week of ${formatDate(weekStart)}';
      }

      groups.putIfAbsent(groupKey, () => []).add(reading);
    }

    groupedReadings.value = groups;
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String getStatusLabel(int systolic, int diastolic) {
    if (systolic >= 140 || diastolic >= 90) {
      return 'High';
    } else if (systolic >= 120 || diastolic >= 80) {
      return 'Elevated';
    }
    return 'Normal';
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'High':
        return const Color(0xFFC62828);
      case 'Elevated':
        return const Color(0xFFF9A825);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  Color getStatusBackgroundColor(String status) {
    switch (status) {
      case 'High':
        return const Color(0xFFFFEBEE);
      case 'Elevated':
        return const Color(0xFFFFFDE7);
      default:
        return const Color(0xFFE8F5E9);
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'High':
        return Icons.warning_rounded;
      default:
        return Icons.favorite_rounded;
    }
  }

  void refresh() {
    loadBloodPressureHistory();
  }
}
