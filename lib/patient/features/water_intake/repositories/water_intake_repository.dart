// lib/patient/features/water_intake/repositories/water_intake_repository.dart

import 'package:dio/dio.dart';
import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/network/api_error_mapper.dart';
import 'package:doctor/patient/features/water_intake/models/today_water_intake.dart';
import 'package:doctor/patient/features/water_intake/models/water_intake_entry.dart';
import 'package:doctor/patient/features/water_intake/models/water_intake_history.dart';
import 'package:doctor/patient/features/water_intake/models/weekly_water_intake.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WaterIntakeRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Get today's water intake
  Future<TodayWaterIntake?> getTodayIntake() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.healthWaterIntakeToday,
      );

      if (response.statusCode == 200) {
        return TodayWaterIntake.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load today\'s water intake.',
      );
      debugPrint('[WATER_INTAKE] Error: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[WATER_INTAKE] Unexpected error: $e');
      return null;
    }
  }

  /// Get water intake history with pagination
  Future<WaterIntakeHistory?> getHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.healthWaterIntake,
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final history = WaterIntakeHistory.fromJson(data);
        history.currentPage = page;
        return history;
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load water intake history.',
      );
      debugPrint('[WATER_INTAKE] Error: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[WATER_INTAKE] Unexpected error: $e');
      return null;
    }
  }

  /// Get weekly water intake history (computed from recent entries)
  Future<WeeklyWaterIntake?> getWeeklyIntake() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.healthWaterIntake,
        queryParameters: {'page_size': 50},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];

        // Group by day of week
        final Map<String, int> dailyTotals = {
          'Mon': 0,
          'Tue': 0,
          'Wed': 0,
          'Thu': 0,
          'Fri': 0,
          'Sat': 0,
          'Sun': 0,
        };

        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));

        for (final item in results) {
          final entry = WaterIntakeEntry.fromJson(item as Map<String, dynamic>);
          final entryDate = entry.logDate;

          // Check if entry is within this week
          if (entryDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
              entryDate.isBefore(now.add(const Duration(days: 1)))) {
            final dayIndex = entryDate.weekday - 1;
            final dayName = [
              'Mon',
              'Tue',
              'Wed',
              'Thu',
              'Fri',
              'Sat',
              'Sun',
            ][dayIndex];
            dailyTotals[dayName] = (dailyTotals[dayName] ?? 0) + entry.amountMl;
          }
        }

        return WeeklyWaterIntake(dailyIntake: dailyTotals);
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load weekly water intake.',
      );
      debugPrint('[WATER_INTAKE] Error: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[WATER_INTAKE] Unexpected error: $e');
      return null;
    }
  }

  /// Log water intake
  Future<WaterIntakeEntry?> logWaterIntake({
    required int amountMl,
    DateTime? logDate,
  }) async {
    try {
      final data = {
        'amount_ml': amountMl,
        if (logDate != null)
          'log_date': logDate.toIso8601String().split('T')[0],
      };

      final response = await _apiClient.post(
        ApiConstants.healthWaterIntake,
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return WaterIntakeEntry.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to log water intake.',
      );
      debugPrint('[WATER_INTAKE] Error logging: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[WATER_INTAKE] Unexpected error: $e');
      return null;
    }
  }
}