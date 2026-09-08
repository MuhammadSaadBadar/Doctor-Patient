// lib/patient/features/diet_plans/repositories/diet_plan_repository.dart

import 'package:dio/dio.dart';
import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/network/api_error_mapper.dart';
import 'package:doctor/patient/features/diet_plans/models/diet_plan.dart';
import 'package:doctor/patient/features/diet_plans/models/paginated_diet_plan_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DietPlanRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Get all diet plans for the patient
  Future<PaginatedDietPlanList?> getDietPlans({
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.dietPlans,
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      if (response.statusCode == 200) {
        return PaginatedDietPlanList.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load diet plans.',
      );
      debugPrint('[DIET_REPO] Error: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[DIET_REPO] Unexpected error: $e');
      return null;
    }
  }

  /// Get active diet plan for the patient
  Future<DietPlan?> getActiveDietPlan() async {
    try {
      final response = await _apiClient.get(ApiConstants.dietPlansActive);

      if (response.statusCode == 200) {
        return DietPlan.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load active diet plan.',
      );
      debugPrint('[DIET_REPO] Error loading active: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[DIET_REPO] Unexpected error: $e');
      return null;
    }
  }

  /// Get a single diet plan by ID
  Future<DietPlan?> getDietPlanById(int id) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.dietPlansDetail}/$id/',
      );

      if (response.statusCode == 200) {
        return DietPlan.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get diet plan details.',
      );
      debugPrint('[DIET_REPO] Error getting plan: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[DIET_REPO] Unexpected error: $e');
      return null;
    }
  }
}
