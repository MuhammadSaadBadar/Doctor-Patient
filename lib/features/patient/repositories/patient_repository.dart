import 'package:dio/dio.dart';
import 'package:doctor/features/patient/models/diet_plan.dart';
import 'package:doctor/features/patient/models/water_intake.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/network/api_error_mapper.dart';
import 'package:doctor/core/services/storage_service.dart';
import 'package:doctor/features/patient/models/patient_card.dart';

class PatientRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final StorageService _storage = Get.find<StorageService>();

  // ==================== PATIENT MANAGEMENT ====================

  /// Get all patients assigned to the current doctor
  Future<List<PatientCard>> getAssignedPatients({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.accountsPatients,
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      debugPrint('[PATIENT] API Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];

        final patients = results.map((item) {
          return PatientCard.fromJson(item as Map<String, dynamic>);
        }).toList();

        debugPrint('[PATIENT] Loaded ${patients.length} patients');
        return patients;
      }

      debugPrint('[PATIENT] API returned status: ${response.statusCode}');
      return [];
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load patients.',
      );
      debugPrint('[PATIENT] Error: ${apiException.message}');
      return [];
    } catch (e) {
      debugPrint('[PATIENT] Unexpected error: $e');
      return [];
    }
  }

  /// Get a single patient by ID
  Future<PatientCard?> getPatientById(int id) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.accountsPatientsDetail}/$id/',
      );

      if (response.statusCode == 200) {
        return PatientCard.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get patient details.',
      );
      debugPrint('[PATIENT] Error getting patient: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[PATIENT] Unexpected error: $e');
      return null;
    }
  }

  // ==================== PATIENT SUMMARY / REPORTS ====================

  /// Get patient summary for dashboard
  Future<Map<String, dynamic>?> getPatientSummary(int patientId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.reportsPatientSummary,
        queryParameters: {'patient_id': patientId},
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get patient summary.',
      );
      debugPrint('[PATIENT] Error getting summary: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[PATIENT] Unexpected error: $e');
      return null;
    }
  }

  // ==================== PREGNANCY PROGRESS ====================

  /// Get patient pregnancy progress (LMP, EDD, current week, trimester)
  Future<Map<String, dynamic>?> getPatientPregnancyProgress(
    int patientId,
  ) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.healthPregnancyProgress,
        queryParameters: {'patient_id': patientId},
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get pregnancy progress.',
      );
      debugPrint(
        '[PATIENT] Error getting pregnancy progress: ${apiException.message}',
      );
      return null;
    } catch (e) {
      debugPrint('[PATIENT] Unexpected error: $e');
      return null;
    }
  }

  // ==================== BLOOD PRESSURE ====================

  /// Get blood pressure readings for a patient
  Future<List<Map<String, dynamic>>> getBloodPressureReadings(
    int patientId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.healthBloodPressure,
        queryParameters: {
          'patient_id': patientId,
          'page': page,
          'page_size': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return (data['results'] as List<dynamic>? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }

      return [];
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get blood pressure readings.',
      );
      debugPrint('[PATIENT] Error getting BP: ${apiException.message}');
      return [];
    } catch (e) {
      debugPrint('[PATIENT] Unexpected error: $e');
      return [];
    }
  }

  /// Get latest blood pressure reading
  Future<Map<String, dynamic>?> getLatestBloodPressure(int patientId) async {
    try {
      final readings = await getBloodPressureReadings(patientId, pageSize: 1);
      return readings.isNotEmpty ? readings.first : null;
    } catch (e) {
      debugPrint('[PATIENT] Error getting latest BP: $e');
      return null;
    }
  }

  // ==================== BLOOD SUGAR ====================

  /// Get blood sugar readings for a patient
  Future<List<Map<String, dynamic>>> getBloodSugarReadings(
    int patientId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.healthBloodSugar,
        queryParameters: {
          'patient_id': patientId,
          'page': page,
          'page_size': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return (data['results'] as List<dynamic>? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }

      return [];
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get blood sugar readings.',
      );
      debugPrint(
        '[PATIENT] Error getting blood sugar: ${apiException.message}',
      );
      return [];
    } catch (e) {
      debugPrint('[PATIENT] Unexpected error: $e');
      return [];
    }
  }

  /// Get latest blood sugar reading
  Future<Map<String, dynamic>?> getLatestBloodSugar(int patientId) async {
    try {
      final readings = await getBloodSugarReadings(patientId, pageSize: 1);
      return readings.isNotEmpty ? readings.first : null;
    } catch (e) {
      debugPrint('[PATIENT] Error getting latest blood sugar: $e');
      return null;
    }
  }

  // ==================== SYMPTOMS ====================

  /// Get symptom logs for a patient
  Future<List<Map<String, dynamic>>> getPatientSymptoms(
    int patientId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.healthSymptoms,
        queryParameters: {
          'patient_id': patientId,
          'page': page,
          'page_size': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return (data['results'] as List<dynamic>? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }

      return [];
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get symptoms.',
      );
      debugPrint('[PATIENT] Error getting symptoms: ${apiException.message}');
      return [];
    } catch (e) {
      debugPrint('[PATIENT] Unexpected error: $e');
      return [];
    }
  }

  // ==================== KICK SESSIONS ====================

  /// Get kick sessions for a patient
  Future<List<Map<String, dynamic>>> getKickSessions(
    int patientId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.healthKickSessions,
        queryParameters: {
          'patient_id': patientId,
          'page': page,
          'page_size': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return (data['results'] as List<dynamic>? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }

      return [];
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get kick sessions.',
      );
      debugPrint(
        '[PATIENT] Error getting kick sessions: ${apiException.message}',
      );
      return [];
    } catch (e) {
      debugPrint('[PATIENT] Unexpected error: $e');
      return [];
    }
  }

  /// Get today's kick count by fetching all sessions and filtering for today
  Future<int> getTodaysKickCount(int patientId) async {
    try {
      // Use UTC for comparison since log_date from API is in UTC
      final nowUtc = DateTime.now().toUtc();
      final todayUtc = DateTime(nowUtc.year, nowUtc.month, nowUtc.day);
      int totalKicks = 0;
      int page = 1;
      const pageSize = 50;
      bool hasMore = true;

      while (hasMore) {
        final sessions = await getKickSessions(
          patientId,
          page: page,
          pageSize: pageSize,
        );

        if (sessions.isEmpty) {
          break;
        }

        bool foundPastDate = false;
        for (final session in sessions) {
          final logDateStr = session['log_date'] as String?;
          if (logDateStr == null) continue;

          // Parse log_date as UTC (API returns UTC date)
          final logDate = DateTime.tryParse('$logDateStr 00:00:00Z');
          if (logDate == null) continue;

          final sessionDateUtc = DateTime(logDate.year, logDate.month, logDate.day);

          if (sessionDateUtc == todayUtc) {
            totalKicks += (session['kick_count'] as int? ?? 0);
          } else if (sessionDateUtc.isBefore(todayUtc)) {
            // Since sessions are ordered by date descending, we can stop
            foundPastDate = true;
            break;
          }
        }

        if (foundPastDate) {
          break;
        }

        hasMore = sessions.length == pageSize;
        page++;
      }

      return totalKicks;
    } catch (e) {
      debugPrint('[PATIENT] Error getting today\'s kick count: $e');
      return 0;
    }
  }
  // ==================== WATER INTAKE ====================

  /// Get water intake entries for a patient
  Future<List<Map<String, dynamic>>> getWaterIntake(
    int patientId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.healthWaterIntake,
        queryParameters: {
          'patient_id': patientId,
          'page': page,
          'page_size': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return (data['results'] as List<dynamic>? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }

      return [];
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get water intake.',
      );
      debugPrint(
        '[PATIENT] Error getting water intake: ${apiException.message}',
      );
      return [];
    } catch (e) {
      debugPrint('[PATIENT] Unexpected error: $e');
      return [];
    }
  }

  /// Get today's water intake total
  Future<int> getTodaysWaterIntake(int patientId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.healthWaterIntakeToday,
        queryParameters: {'patient_id': patientId},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['total_ml'] as int? ?? 0;
      }

      return 0;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get today\'s water intake.',
      );
      debugPrint(
        '[PATIENT] Error getting water intake today: ${apiException.message}',
      );
      return 0;
    } catch (e) {
      debugPrint('[PATIENT] Unexpected error: $e');
      return 0;
    }
  }

  /// Log water intake entry for a patient (Doctor can log on behalf of patient)
  Future<WaterIntakeEntry?> logWaterIntake({
    required int patientId,
    required int amountMl,
    DateTime? logDate,
  }) async {
    try {
      final data = {
        'patient_id': patientId,
        'amount_ml': amountMl,
        if (logDate != null)
          'log_date': logDate.toIso8601String().split('T')[0],
      };

      final response = await _apiClient.post(
        ApiConstants.healthWaterIntake,
        data: data,
      );

      if (response.statusCode == 201) {
        return WaterIntakeEntry.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to log water intake.',
      );
      debugPrint(
        '[PATIENT] Error logging water intake: ${apiException.message}',
      );
      return null;
    } catch (e) {
      debugPrint('[PATIENT] Unexpected error: $e');
      return null;
    }
  }

  // ==================== MEDICINE REMINDERS ====================

  /// Get medicine reminders for a patient
  Future<List<Map<String, dynamic>>> getMedicineReminders(
    int patientId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.medicinesReminders,
        queryParameters: {
          'patient_id': patientId,
          'page': page,
          'page_size': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return (data['results'] as List<dynamic>? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }

      return [];
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get medicine reminders.',
      );
      debugPrint(
        '[PATIENT] Error getting medicine reminders: ${apiException.message}',
      );
      return [];
    } catch (e) {
      debugPrint('[PATIENT] Unexpected error: $e');
      return [];
    }
  }

  // ==================== APPOINTMENTS ====================

  /// Get appointments for a patient
  Future<List<Map<String, dynamic>>> getPatientAppointments(
    int patientId, {
    String status = 'upcoming',
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.appointments,
        queryParameters: {
          'patient_id': patientId,
          'status': status,
          'page': page,
          'page_size': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return (data['results'] as List<dynamic>? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }

      return [];
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get appointments.',
      );
      debugPrint(
        '[PATIENT] Error getting appointments: ${apiException.message}',
      );
      return [];
    } catch (e) {
      debugPrint('[PATIENT] Unexpected error: $e');
      return [];
    }
  }

  // ==================== SURGICAL PROCEDURES ====================

  /// Get surgical procedures for a patient
  Future<List<Map<String, dynamic>>> getSurgicalProcedures(
    int patientId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.healthSurgicalProcedures,
        queryParameters: {
          'patient_id': patientId,
          'page': page,
          'page_size': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return (data['results'] as List<dynamic>? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }

      return [];
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get surgical procedures.',
      );
      debugPrint(
        '[PATIENT] Error getting surgical procedures: ${apiException.message}',
      );
      return [];
    } catch (e) {
      debugPrint('[PATIENT] Unexpected error: $e');
      return [];
    }
  }

  // ==================== BABY SIZE REFERENCE ====================

  /// Get baby size reference by week
  Future<Map<String, dynamic>?> getBabySizeReference(int week) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.healthBabySizeDetail}/$week/',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get baby size reference.',
      );
      debugPrint('[PATIENT] Error getting baby size: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[PATIENT] Unexpected error: $e');
      return null;
    }
  }

  // ==================== DIET PLANS ====================

  /// Get diet plans for a patient
  Future<List<Map<String, dynamic>>> getPatientDietPlans(
    int patientId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.dietPlans,
        queryParameters: {
          'patient_id': patientId,
          'page': page,
          'page_size': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return (data['results'] as List<dynamic>? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }

      return [];
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get diet plans.',
      );
      debugPrint('[PATIENT] Error getting diet plans: ${apiException.message}');
      return [];
    } catch (e) {
      debugPrint('[PATIENT] Unexpected error: $e');
      return [];
    }
  }

  /// Get a single diet plan by ID
  Future<Map<String, dynamic>?> getDietPlan(String planId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.dietPlansDetail}/$planId/',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get diet plan.',
      );
      debugPrint('[PATIENT] Error getting diet plan: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[PATIENT] Unexpected error: $e');
      return null;
    }
  }

  /// Get active diet plan for a patient
  Future<Map<String, dynamic>?> getActiveDietPlan(int patientId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.dietPlansActive,
        queryParameters: {'patient_id': patientId},
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get active diet plan.',
      );
      debugPrint(
        '[PATIENT] Error getting active diet plan: ${apiException.message}',
      );
      return null;
    } catch (e) {
      debugPrint('[PATIENT] Unexpected error: $e');
      return null;
    }
  }

  /// Create a new diet plan
  Future<Map<String, dynamic>?> createDietPlan(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.dietPlans,
        data: data,
      );

      if (response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to create diet plan.',
      );
      debugPrint('[PATIENT] Error creating diet plan: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[PATIENT] Unexpected error: $e');
      return null;
    }
  }

  /// Update a diet plan
  Future<Map<String, dynamic>?> updateDietPlan(
    String planId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.dietPlansDetail}/$planId/',
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to update diet plan.',
      );
      debugPrint('[PATIENT] Error updating diet plan: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[PATIENT] Unexpected error: $e');
      return null;
    }
  }

  // ==================== DIET PLANS ====================

  /// Get diet plans for a patient with pagination
  Future<DietPlanListResult> getDietPlansPaginated({
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
        ApiConstants.dietPlans,
        queryParameters: queryParams,
      );

      debugPrint('[DIET_PLANS] API Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];
        final totalCount = data['count'] as int? ?? 0;
        final next = data['next'] as String?;

        final plans = results.map((item) {
          return DietPlan.fromJson(item as Map<String, dynamic>);
        }).toList();

        debugPrint('[DIET_PLANS] Loaded ${plans.length} plans of $totalCount');
        return DietPlanListResult(
          plans: plans,
          totalCount: totalCount,
          hasNext: next != null,
        );
      }

      debugPrint('[DIET_PLANS] API returned status: ${response.statusCode}');
      return DietPlanListResult(plans: [], totalCount: 0, hasNext: false);
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load diet plans.',
      );
      debugPrint('[DIET_PLANS] Error: ${apiException.message}');
      return DietPlanListResult(plans: [], totalCount: 0, hasNext: false);
    } catch (e) {
      debugPrint('[DIET_PLANS] Unexpected error: $e');
      return DietPlanListResult(plans: [], totalCount: 0, hasNext: false);
    }
  }

  /// Get ALL diet plans for a patient (no pagination) - for stable numbering
  Future<List<DietPlan>> getAllDietPlans(int patientId) async {
    try {
      final List<DietPlan> allPlans = [];
      int page = 1;
      const pageSize = 50;
      bool hasNext = true;

      while (hasNext) {
        final result = await getDietPlansPaginated(
          patientId: patientId,
          page: page,
          pageSize: pageSize,
        );
        allPlans.addAll(result.plans);
        hasNext = result.hasNext;
        page++;
      }

      // Sort by ID ascending for stable chronological numbering
      allPlans.sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));

      // Assign stable plan numbers
      for (int i = 0; i < allPlans.length; i++) {
        allPlans[i].setPlanNumber(i + 1);
      }

      debugPrint('[DIET_PLANS] Loaded all ${allPlans.length} plans with stable numbering');
      return allPlans;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load diet plans.',
      );
      debugPrint('[DIET_PLANS] Error loading all plans: ${apiException.message}');
      return [];
    } catch (e) {
      debugPrint('[DIET_PLANS] Unexpected error loading all plans: $e');
      return [];
    }
  }

  /// Delete a diet plan (doctor/admin only)
  Future<bool> deleteDietPlan(String planId) async {
    try {
      final response = await _apiClient.delete(
        '${ApiConstants.dietPlansDetail}/$planId/',
      );

      if (response.statusCode == 204) {
        debugPrint('[DIET_PLANS] Deleted plan $planId');
        return true;
      }

      debugPrint('[DIET_PLANS] Delete failed with status: ${response.statusCode}');
      return false;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to delete diet plan.',
      );
      debugPrint('[DIET_PLANS] Error deleting plan: ${apiException.message}');
      return false;
    } catch (e) {
      debugPrint('[DIET_PLANS] Unexpected error deleting plan: $e');
      return false;
    }
  }
}

// Result class for paginated diet plans
class DietPlanListResult {
  final List<DietPlan> plans;
  final int totalCount;
  final bool hasNext;

  DietPlanListResult({
    required this.plans,
    required this.totalCount,
    required this.hasNext,
  });
}
