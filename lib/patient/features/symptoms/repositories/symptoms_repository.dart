// lib/patient/features/symptoms/repositories/symptoms_repository.dart

import 'package:dio/dio.dart';
import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/network/api_error_mapper.dart';
import 'package:doctor/patient/features/symptoms/models/symptom_log.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SymptomsRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<List<SymptomLog>> getSymptomLogs() async {
    try {
      final response = await _apiClient.get(ApiConstants.healthSymptoms);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];
        return results
            .map((e) => SymptomLog.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      debugPrint('[SYMPTOMS] API returned status: ${response.statusCode}');
      return [];
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load symptoms.',
      );
      debugPrint('[SYMPTOMS] Error: ${apiException.message}');
      return [];
    } catch (e) {
      debugPrint('[SYMPTOMS] Unexpected error: $e');
      return [];
    }
  }

  Future<SymptomLog?> createOrUpdateSymptomLog({
    required String logDate,
    required List<int> symptomIds,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.healthSymptoms,
        data: {
          'log_date': logDate,
          'symptom_ids': symptomIds,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return SymptomLog.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to save symptom log.',
      );
      debugPrint('[SYMPTOMS] Error saving: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[SYMPTOMS] Unexpected error: $e');
      return null;
    }
  }

}