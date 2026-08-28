import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/network/api_error_mapper.dart';
import 'package:doctor/core/services/storage_service.dart';
import 'package:doctor/features/dashboard/controllers/dashboard_controller.dart';

class DashboardRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final StorageService _storage = Get.find<StorageService>();

  Future<DoctorDashboardData?> getDoctorDashboard() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.reportsDoctorDashboard,
      );

      debugPrint('[DASHBOARD] API Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        debugPrint('[DASHBOARD] Data received: $data');
        return DoctorDashboardData.fromJson(data);
      }

      debugPrint('[DASHBOARD] API returned status: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load dashboard data.',
      );
      debugPrint('[DASHBOARD] Error: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[DASHBOARD] Unexpected error: $e');
      return null;
    }
  }
}
