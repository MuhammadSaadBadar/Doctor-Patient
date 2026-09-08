// lib/patient/features/medicine_reminders/repositories/medicine_reminder_repository.dart

import 'package:dio/dio.dart';
import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/network/api_error_mapper.dart';
import 'package:doctor/patient/features/medicine_reminders/models/medicine_intake_log.dart';
import 'package:doctor/patient/features/medicine_reminders/models/medicine_reminder.dart';
import 'package:doctor/patient/features/medicine_reminders/models/paginated_intake_log_list.dart';
import 'package:doctor/patient/features/medicine_reminders/models/paginated_reminder_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MedicineReminderRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Get all medicine reminders for the patient
  Future<PaginatedReminderList?> getReminders({
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.medicinesReminders,
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      if (response.statusCode == 200) {
        return PaginatedReminderList.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load medicine reminders.',
      );
      debugPrint('[MEDICINE_REPO] Error: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[MEDICINE_REPO] Unexpected error: $e');
      return null;
    }
  }

  /// Get a single medicine reminder by ID
  Future<MedicineReminder?> getReminderById(int id) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.medicinesReminders}$id/',
      );

      if (response.statusCode == 200) {
        return MedicineReminder.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get reminder details.',
      );
      debugPrint(
        '[MEDICINE_REPO] Error getting reminder: ${apiException.message}',
      );
      return null;
    } catch (e) {
      debugPrint('[MEDICINE_REPO] Unexpected error: $e');
      return null;
    }
  }

  /// Create a new medicine reminder
  Future<MedicineReminder?> createReminder({
    required String medicineName,
    required String dosage,
    required int timesPerDay,
    required List<String> reminderTimes,
    required DateTime startDate,
    DateTime? endDate,
    bool isActive = true,
  }) async {
    try {
      final data = {
        'medicine_name': medicineName,
        'dosage': dosage,
        'times_per_day': timesPerDay,
        'reminder_times': reminderTimes,
        'start_date': startDate.toIso8601String().split('T')[0],
        'is_active': isActive,
        if (endDate != null)
          'end_date': endDate.toIso8601String().split('T')[0],
      };

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
        defaultMessage: 'Failed to create reminder.',
      );
      debugPrint('[MEDICINE_REPO] Error creating: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[MEDICINE_REPO] Unexpected error: $e');
      return null;
    }
  }

  /// Update an existing medicine reminder
  Future<MedicineReminder?> updateReminder({
    required int id,
    String? medicineName,
    String? dosage,
    int? timesPerDay,
    List<String>? reminderTimes,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (medicineName != null) data['medicine_name'] = medicineName;
      if (dosage != null) data['dosage'] = dosage;
      if (timesPerDay != null) data['times_per_day'] = timesPerDay;
      if (reminderTimes != null) data['reminder_times'] = reminderTimes;
      if (startDate != null) {
        data['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        data['end_date'] = endDate.toIso8601String().split('T')[0];
      }
      if (isActive != null) data['is_active'] = isActive;

      final response = await _apiClient.patch(
        '${ApiConstants.medicinesReminders}$id/',
        data: data,
      );

      if (response.statusCode == 200) {
        return MedicineReminder.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to update reminder.',
      );
      debugPrint('[MEDICINE_REPO] Error updating: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[MEDICINE_REPO] Unexpected error: $e');
      return null;
    }
  }

  /// Toggle reminder active status
  Future<MedicineReminder?> toggleReminder(int id) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConstants.medicinesReminders}$id/',
        data: {
          'is_active': true, // This will be toggled server-side
        },
      );

      if (response.statusCode == 200) {
        return MedicineReminder.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to toggle reminder.',
      );
      debugPrint('[MEDICINE_REPO] Error toggling: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[MEDICINE_REPO] Unexpected error: $e');
      return null;
    }
  }

  /// Delete a medicine reminder
  Future<bool> deleteReminder(int id) async {
    try {
      final response = await _apiClient.delete(
        '${ApiConstants.medicinesReminders}$id/',
      );

      if (response.statusCode == 204) {
        return true;
      }

      return false;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to delete reminder.',
      );
      debugPrint('[MEDICINE_REPO] Error deleting: ${apiException.message}');
      return false;
    } catch (e) {
      debugPrint('[MEDICINE_REPO] Unexpected error: $e');
      return false;
    }
  }

  Future<PaginatedIntakeLogList?> getIntakeLogs({
    int page = 1,
    int pageSize = 50,
    int? reminderId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'page_size': pageSize,
      };
      if (reminderId != null) {
        queryParams['reminder_id'] = reminderId;
      }
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _apiClient.get(
        ApiConstants.medicinesIntakeLogs,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return PaginatedIntakeLogList.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load intake logs.',
      );
      debugPrint('[MEDICINE_REPO] Error loading logs: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[MEDICINE_REPO] Unexpected error: $e');
      return null;
    }
  }

  /// Log medicine intake (taken or skipped)
  /// POST /medicines/reminders/{id}/log-intake/
  Future<MedicineIntakeLog?> logIntake({
    required int reminderId,
    required String status,
    DateTime? scheduledFor,
  }) async {
    try {
      final data = {
        'status': status,
        if (scheduledFor != null)
          'scheduled_for': scheduledFor.toIso8601String(),
      };

      final response = await _apiClient.post(
        '${ApiConstants.medicinesReminders}$reminderId${ApiConstants.medicinesReminderLogIntakeSuffix}',
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
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
      debugPrint('[MEDICINE_REPO] Error logging intake: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[MEDICINE_REPO] Unexpected error logging intake: $e');
      return null;
    }
  }
}
