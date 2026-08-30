// lib/patient/features/vitals/repositories/vitals_repository.dart

import 'package:dio/dio.dart';
import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/network/api_error_mapper.dart';
import 'package:doctor/patient/features/vitals/models/vital_reading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VitalsRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<List<BloodPressureReading>> getBloodPressureHistory() async {
    try {
      final response = await _apiClient.get(ApiConstants.healthBloodPressure);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];
        return results
            .map((e) => BloodPressureReading.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      debugPrint('[VITALS] Error getting BP history: $e');
      return [];
    } catch (e) {
      debugPrint('[VITALS] Unexpected error: $e');
      return [];
    }
  }

  Future<List<BloodSugarReading>> getBloodSugarHistory() async {
    try {
      final response = await _apiClient.get(ApiConstants.healthBloodSugar);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];
        return results
            .map((e) => BloodSugarReading.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      debugPrint('[VITALS] Error getting sugar history: $e');
      return [];
    } catch (e) {
      debugPrint('[VITALS] Unexpected error: $e');
      return [];
    }
  }

  Future<BloodPressureReading?> logBloodPressure({
    required int systolic,
    required int diastolic,
    int? pulse,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.healthBloodPressure,
        data: {
          'systolic': systolic,
          'diastolic': diastolic,
          if (pulse != null) 'pulse': pulse,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return BloodPressureReading.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to log blood pressure.',
      );
      debugPrint('[VITALS] Error logging BP: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[VITALS] Unexpected error: $e');
      return null;
    }
  }

  Future<BloodSugarReading?> logBloodSugar({
    required int valueMgDl,
    required String readingContext,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.healthBloodSugar,
        data: {
          'value_mg_dl': valueMgDl,
          'reading_context': readingContext,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return BloodSugarReading.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to log blood sugar.',
      );
      debugPrint('[VITALS] Error logging sugar: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[VITALS] Unexpected error: $e');
      return null;
    }
  }
}