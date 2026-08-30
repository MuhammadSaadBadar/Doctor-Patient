// lib/patient/features/kick_counter/repositories/kick_counter_repository.dart

import 'package:dio/dio.dart';
import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/network/api_error_mapper.dart';
import 'package:doctor/patient/features/kick_counter/models/kick_session.dart';
import 'package:doctor/patient/features/kick_counter/models/paginated_kick_session.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KickCounterRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Get paginated kick sessions (history)
  Future<PaginatedKickSessionList?> getPaginatedSessions({
    int page = 1,
    int pageSize = 20,
    int? patientId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      if (patientId != null) {
        queryParams['patient_id'] = patientId;
      }

      final response = await _apiClient.get(
        ApiConstants.healthKickSessions,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return PaginatedKickSessionList.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      debugPrint('[KICK_COUNTER] API returned status: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load kick sessions.',
      );
      debugPrint('[KICK_COUNTER] Error: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[KICK_COUNTER] Unexpected error: $e');
      return null;
    }
  }

  /// Start a new kick session
  Future<KickSession?> startSession() async {
    try {
      final response = await _apiClient.post(
        ApiConstants.healthKickSessions,
        data: {},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return KickSession.fromJson(response.data as Map<String, dynamic>);
      }

      debugPrint('[KICK_COUNTER] Start session failed: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to start kick session.',
      );
      debugPrint('[KICK_COUNTER] Error starting session: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[KICK_COUNTER] Unexpected error: $e');
      return null;
    }
  }

  /// End a kick session
  Future<KickSession?> endSession(int sessionId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.healthKickSessionsDetail}/$sessionId${ApiConstants.healthKickSessionEndSuffix}',
        data: {},
      );

      if (response.statusCode == 200) {
        return KickSession.fromJson(response.data as Map<String, dynamic>);
      }

      debugPrint('[KICK_COUNTER] End session failed: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to end kick session.',
      );
      debugPrint('[KICK_COUNTER] Error ending session: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[KICK_COUNTER] Unexpected error: $e');
      return null;
    }
  }

  /// Record a kick (tap)
  Future<KickSession?> recordKick(int sessionId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.healthKickSessionsDetail}/$sessionId${ApiConstants.healthKickSessionTapSuffix}',
        data: {},
      );

      if (response.statusCode == 200) {
        return KickSession.fromJson(response.data as Map<String, dynamic>);
      }

      debugPrint('[KICK_COUNTER] Record kick failed: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to record kick.',
      );
      debugPrint('[KICK_COUNTER] Error recording kick: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[KICK_COUNTER] Unexpected error: $e');
      return null;
    }
  }

  /// Get a single session by ID
  Future<KickSession?> getSession(int sessionId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.healthKickSessionsDetail}/$sessionId/',
      );

      if (response.statusCode == 200) {
        return KickSession.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      debugPrint('[KICK_COUNTER] Error getting session: $e');
      return null;
    } catch (e) {
      debugPrint('[KICK_COUNTER] Unexpected error: $e');
      return null;
    }
  }
}