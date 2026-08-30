// lib/features/patient/controllers/blood_sugar_history_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor/doctor/features/patient/repositories/doc_patient_repository.dart';

class DoctorBloodSugarHistoryController extends GetxController {
  final DoctorPatientRepository _repository =
      Get.find<DoctorPatientRepository>();

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
      loadBloodSugarHistory();
    }
  }

  Future<void> loadBloodSugarHistory() async {
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
        '[BS_HISTORY] Loading blood sugar history for patient $_patientId',
      );

      // Fetch all blood sugar readings (no pagination limit, get all)
      final bsReadings = await _repository.getBloodSugarReadings(
        _patientId!,
        pageSize: 100,
      );

      if (bsReadings.isNotEmpty) {
        // Sort by recorded_at descending (most recent first)
        bsReadings.sort((a, b) {
          final dateA = DateTime.tryParse(a['recorded_at']?.toString() ?? '');
          final dateB = DateTime.tryParse(b['recorded_at']?.toString() ?? '');
          if (dateA == null || dateB == null) return 0;
          return dateB.compareTo(dateA);
        });

        readings.value = bsReadings;
        groupReadingsByDate(bsReadings);
      } else {
        readings.value = [];
        groupedReadings.value = {};
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value =
          'Failed to load blood sugar history. Please try again.';
      debugPrint('[BS_HISTORY] Error: $e');
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
        groupKey = 'Week of ${_formatDate(weekStart)}';
      }

      groups.putIfAbsent(groupKey, () => []).add(reading);
    }

    groupedReadings.value = groups;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String getContextLabel(String? context) {
    switch (context) {
      case 'fasting':
        return 'Fasting';
      case 'post_meal':
        return 'Post-Meal';
      case 'random':
        return 'Random';
      default:
        return 'Unknown';
    }
  }

  Color getContextColor(String? context) {
    switch (context) {
      case 'fasting':
        return const Color(0xFF1565C0);
      case 'post_meal':
        return const Color(0xFFE65100);
      case 'random':
        return const Color(0xFF616161);
      default:
        return Colors.grey;
    }
  }

  Color getContextBgColor(String? context) {
    switch (context) {
      case 'fasting':
        return const Color(0xFFE3F2FD);
      case 'post_meal':
        return const Color(0xFFFFF3E0);
      case 'random':
        return const Color(0xFFF5F5F5);
      default:
        return Colors.grey.shade200;
    }
  }

  IconData getContextIcon(String? context) {
    switch (context) {
      case 'fasting':
        return Icons.dark_mode_rounded;
      case 'post_meal':
        return Icons.restaurant_rounded;
      case 'random':
        return Icons.schedule_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String getStatusLabel(int value, String? context) {
    if (context == 'fasting') {
      if (value < 100) return 'Normal';
      if (value < 126) return 'Pre-diabetic';
      return 'Diabetic';
    } else {
      if (value < 140) return 'Normal';
      if (value < 200) return 'Pre-diabetic';
      return 'Diabetic';
    }
  }

  Color getStatusColor(int value, String? context) {
    if (context == 'fasting') {
      if (value < 100) return const Color(0xFF2E7D32);
      if (value < 126) return const Color(0xFFF9A825);
      return const Color(0xFFC62828);
    } else {
      if (value < 140) return const Color(0xFF2E7D32);
      if (value < 200) return const Color(0xFFF9A825);
      return const Color(0xFFC62828);
    }
  }

  Color getStatusBgColor(int value, String? context) {
    if (context == 'fasting') {
      if (value < 100) return const Color(0xFFE8F5E9);
      if (value < 126) return const Color(0xFFFFFDE7);
      return const Color(0xFFFFEBEE);
    } else {
      if (value < 140) return const Color(0xFFE8F5E9);
      if (value < 200) return const Color(0xFFFFFDE7);
      return const Color(0xFFFFEBEE);
    }
  }

  void refresh() {
    loadBloodSugarHistory();
  }
}
