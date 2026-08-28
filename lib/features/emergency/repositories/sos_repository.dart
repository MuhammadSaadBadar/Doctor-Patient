// lib/features/emergency/repositories/sos_repository.dart

import 'package:dio/dio.dart';
import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/network/api_error_mapper.dart';
import 'package:doctor/features/emergency/models/sos_event.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SosRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Get list of SOS events (role-scoped)
  Future<List<SosEvent>> getSosEvents({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _apiClient.get(
        ApiConstants.emergencySos,
        queryParameters: queryParams,
      );

      debugPrint('[SOS] API Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];
        return results.map((item) {
          return SosEvent.fromJson(item as Map<String, dynamic>);
        }).toList();
      }

      return [];
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load SOS events.',
      );
      debugPrint('[SOS] Error: ${apiException.message}');
      return [];
    } catch (e) {
      debugPrint('[SOS] Unexpected error: $e');
      return [];
    }
  }

  /// Get a single SOS event by ID
  Future<SosEvent?> getSosEvent(String id) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.emergencySosDetail}/$id/',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return SosEvent.fromJson(data);
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get SOS event.',
      );
      debugPrint('[SOS] Error getting event: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[SOS] Unexpected error: $e');
      return null;
    }
  }

  /// Get count of active SOS events for dashboard metric
  Future<int> getActiveSosCount() async {
    try {
      final queryParams = <String, dynamic>{
        'status': 'active',
        'page': 1,
        'page_size': 1,
      };

      final response = await _apiClient.get(
        ApiConstants.emergencySos,
        queryParameters: queryParams,
      );

      debugPrint('[SOS] Active count API Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final count = data['count'] as int? ?? 0;
        return count;
      }

      return 0;
    } on DioException catch (e) {
      debugPrint('[SOS] Error getting active count: ${e.message}');
      return 0;
    } catch (e) {
      debugPrint('[SOS] Unexpected error getting active count: $e');
      return 0;
    }
  }

  /// Resolve an SOS event
  Future<SosEvent?> resolveSosEvent({
    required String id,
    required String status, // 'resolved' or 'false_alarm'
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.emergencySosDetail}/$id${ApiConstants.emergencySosResolveSuffix}',
        data: {'status': status},
      );

      debugPrint('[SOS] Resolve response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return SosEvent.fromJson(data);
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to resolve SOS event.',
      );
      debugPrint('[SOS] Error resolving: ${apiException.message}');
      throw apiException;
    } catch (e) {
      debugPrint('[SOS] Unexpected error: $e');
      throw Exception('Failed to resolve SOS event. Please try again.');
    }
  }
}
