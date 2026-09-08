// lib/features/patient/repositories/medicine_reminder_repository.dart

import 'package:dio/dio.dart';
import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/network/api_error_mapper.dart';
import 'package:doctor/doctor/features/patient/models/doc_medicine_reminder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorMedicineReminderRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Get medicine reminders for a patient
  Future<MedicineReminderListResult> getMedicineReminders({
    required int patientId,
    int page = 1,
    int pageSize = 20,
    bool activeOnly = false,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'page_size': pageSize,
      };
      queryParams['patient_id'] = patientId;

      final response = await _apiClient.get(
        ApiConstants.medicinesReminders,
        queryParameters: queryParams,
      );

      debugPrint(
        '[MEDICINE_REMINDER] API Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];
        final totalCount = data['count'] as int? ?? 0;
        final next = data['next'] as String?;

        var reminders = results.map((item) {
          return MedicineReminder.fromJson(item as Map<String, dynamic>);
        }).toList();

        // Filter active only if requested
        if (activeOnly) {
          reminders = reminders.where((r) => r.isActive).toList();
        }

        debugPrint(
          '[MEDICINE_REMINDER] Loaded ${reminders.length} reminders of $totalCount',
        );
        return MedicineReminderListResult(
          reminders: reminders,
          totalCount: totalCount,
          hasNext: next != null,
        );
      }

      debugPrint(
        '[MEDICINE_REMINDER] API returned status: ${response.statusCode}',
      );
      return MedicineReminderListResult(
        reminders: [],
        totalCount: 0,
        hasNext: false,
      );
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load medicine reminders.',
      );
      debugPrint('[MEDICINE_REMINDER] Error: ${apiException.message}');
      return MedicineReminderListResult(
        reminders: [],
        totalCount: 0,
        hasNext: false,
      );
    } catch (e) {
      debugPrint('[MEDICINE_REMINDER] Unexpected error: $e');
      return MedicineReminderListResult(
        reminders: [],
        totalCount: 0,
        hasNext: false,
      );
    }
  }

  /// Get a single medicine reminder by ID
  Future<MedicineReminder?> getMedicineReminder(String reminderId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.medicinesRemindersDetail}/$reminderId/',
      );

      if (response.statusCode == 200) {
        return MedicineReminder.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get medicine reminder.',
      );
      debugPrint(
        '[MEDICINE_REMINDER] Error getting reminder: ${apiException.message}',
      );
      return null;
    } catch (e) {
      debugPrint('[MEDICINE_REMINDER] Unexpected error: $e');
      return null;
    }
  }

  /// Create a new medicine reminder
  Future<MedicineReminder?> createMedicineReminder(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.medicinesReminders,
        data: data,
      );

      if (response.statusCode == 201) {
        return MedicineReminder.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to create medicine reminder.',
      );
      debugPrint(
        '[MEDICINE_REMINDER] Error creating reminder: ${apiException.message}',
      );
      return null;
    } catch (e) {
      debugPrint('[MEDICINE_REMINDER] Unexpected error: $e');
      return null;
    }
  }

  /// Update a medicine reminder
  Future<MedicineReminder?> updateMedicineReminder(
    String reminderId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConstants.medicinesRemindersDetail}/$reminderId/',
        data: data,
      );

      if (response.statusCode == 200) {
        return MedicineReminder.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to update medicine reminder.',
      );
      debugPrint(
        '[MEDICINE_REMINDER] Error updating reminder: ${apiException.message}',
      );
      return null;
    } catch (e) {
      debugPrint('[MEDICINE_REMINDER] Unexpected error: $e');
      return null;
    }
  }

  /// Toggle active status of a medicine reminder
  Future<MedicineReminder?> toggleMedicineReminder(
    String reminderId,
    bool isActive,
  ) async {
    return updateMedicineReminder(reminderId, {'is_active': isActive});
  }

  /// Delete a medicine reminder
  Future<bool> deleteMedicineReminder(String reminderId) async {
    try {
      final response = await _apiClient.delete(
        '${ApiConstants.medicinesRemindersDetail}/$reminderId/',
      );

      return response.statusCode == 204;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to delete medicine reminder.',
      );
      debugPrint(
        '[MEDICINE_REMINDER] Error deleting reminder: ${apiException.message}',
      );
      return false;
    } catch (e) {
      debugPrint('[MEDICINE_REMINDER] Unexpected error: $e');
      return false;
    }
  }

  /// Log intake for a medicine reminder
  Future<MedicineIntakeLog?> logIntake({
    required String reminderId,
    required String status, // 'taken' or 'skipped'
    DateTime? scheduledFor,
  }) async {
    try {
      final data = {
        'status': status,
        if (scheduledFor != null)
          'scheduled_for': scheduledFor.toIso8601String(),
      };

      final response = await _apiClient.post(
        '${ApiConstants.medicinesRemindersDetail}/$reminderId${ApiConstants.medicinesReminderLogIntakeSuffix}',
        data: data,
      );

      if (response.statusCode == 201) {
        return MedicineIntakeLog.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to log intake.',
      );
      debugPrint(
        '[MEDICINE_REMINDER] Error logging intake: ${apiException.message}',
      );
      return null;
    } catch (e) {
      debugPrint('[MEDICINE_REMINDER] Unexpected error: $e');
      return null;
    }
  }

  /// Get intake logs for a patient
  Future<List<MedicineIntakeLog>> getIntakeLogs({
    int? patientId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'page_size': pageSize,
      };
      if (patientId != null) {
        queryParams['patient_id'] = patientId;
      }

      final response = await _apiClient.get(
        ApiConstants.medicinesIntakeLogs,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];
        return results.map((item) {
          return MedicineIntakeLog.fromJson(item as Map<String, dynamic>);
        }).toList();
      }

      return [];
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get intake logs.',
      );
      debugPrint(
        '[MEDICINE_REMINDER] Error getting intake logs: ${apiException.message}',
      );
      return [];
    } catch (e) {
      debugPrint('[MEDICINE_REMINDER] Unexpected error: $e');
      return [];
    }
  }
}
