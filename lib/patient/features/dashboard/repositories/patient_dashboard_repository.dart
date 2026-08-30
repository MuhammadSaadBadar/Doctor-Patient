// lib/patient/features/dashboard/repositories/patient_dashboard_repository.dart

import 'package:dio/dio.dart';
import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/network/api_error_mapper.dart';
import 'package:doctor/patient/features/dashboard/models/patient_summary.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PatientDashboardRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<PatientSummary?> getPatientSummary() async {
    try {
      final response = await _apiClient.get(ApiConstants.reportsPatientSummary);

      if (response.statusCode == 200) {
        return PatientSummary.fromJson(response.data as Map<String, dynamic>);
      }

      debugPrint('[PATIENT_DASHBOARD] API returned status: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load dashboard data.',
      );
      debugPrint('[PATIENT_DASHBOARD] Error: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[PATIENT_DASHBOARD] Unexpected error: $e');
      return null;
    }
  }

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
      debugPrint('[PATIENT_DASHBOARD] Error getting baby size: $e');
      return null;
    } catch (e) {
      debugPrint('[PATIENT_DASHBOARD] Unexpected error: $e');
      return null;
    }
  }
}