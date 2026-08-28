// lib/features/notifications/repositories/notification_repository.dart

import 'package:dio/dio.dart';
import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/network/api_error_mapper.dart';
import 'package:doctor/features/notifications/models/notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Get notification list (paginated)
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.notifications,
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      debugPrint('[NOTIFICATION] API Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];
        return results.map((item) {
          return NotificationModel.fromJson(item as Map<String, dynamic>);
        }).toList();
      }

      return [];
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load notifications.',
      );
      debugPrint('[NOTIFICATION] Error: ${apiException.message}');
      return [];
    } catch (e) {
      debugPrint('[NOTIFICATION] Unexpected error: $e');
      return [];
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.notificationsUnreadCount,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['unread_count'] as int? ?? 0;
      }

      return 0;
    } catch (e) {
      debugPrint('[NOTIFICATION] Error getting unread count: $e');
      return 0;
    }
  }

  /// Mark a single notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.notificationsDetail}/$notificationId${ApiConstants.notificationMarkReadSuffix}',
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to mark notification as read.',
      );
      debugPrint(
        '[NOTIFICATION] Error marking as read: ${apiException.message}',
      );
      return false;
    } catch (e) {
      debugPrint('[NOTIFICATION] Unexpected error: $e');
      return false;
    }
  }

  /// Mark all notifications as read
  Future<int> markAllAsRead() async {
    try {
      final response = await _apiClient.post(
        ApiConstants.notificationsMarkAllRead,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final detail = data['detail'] as String? ?? '0';
        final count =
            int.tryParse(detail.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return count;
      }

      return 0;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to mark all as read.',
      );
      debugPrint(
        '[NOTIFICATION] Error marking all as read: ${apiException.message}',
      );
      return 0;
    } catch (e) {
      debugPrint('[NOTIFICATION] Unexpected error: $e');
      return 0;
    }
  }
}
