// lib/features/patient/repositories/send_message_repository.dart

import 'package:dio/dio.dart';
import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/network/api_error_mapper.dart';
import 'package:doctor/doctor/features/patient/models/doc_send_message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorSendMessageRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Send a message to a patient (doctor only)
  Future<SendMessageResponse?> sendMessageToPatient(
    SendMessageRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.notificationsSendToPatient,
        data: request.toJson(),
      );

      debugPrint('[SEND_MESSAGE] API Response status: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        debugPrint('[SEND_MESSAGE] Message sent successfully');
        return SendMessageResponse.fromJson(data);
      }

      debugPrint('[SEND_MESSAGE] API returned status: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to send message. Please try again.',
      );
      debugPrint('[SEND_MESSAGE] Error: ${apiException.message}');
      throw apiException;
    } catch (e) {
      debugPrint('[SEND_MESSAGE] Unexpected error: $e');
      throw Exception('Failed to send message. Please try again.');
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
      debugPrint('[SEND_MESSAGE] Error getting unread count: $e');
      return 0;
    }
  }
}
