// lib/patient/features/ai_assistant/repositories/ai_assistant_repository.dart

import 'package:dio/dio.dart';
import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/network/api_error_mapper.dart';
import 'package:doctor/core/network/api_exceptions.dart';
import 'package:doctor/patient/features/ai_assistant/models/chat_message.dart';
import 'package:doctor/patient/features/ai_assistant/models/chat_session.dart';
import 'package:doctor/patient/features/ai_assistant/models/paginated_chat_message_list.dart';
import 'package:doctor/patient/features/ai_assistant/models/paginated_chat_session_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AIAssistantRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  // ==================== SESSIONS ====================

  /// Get all chat sessions
  Future<PaginatedChatSessionList?> getSessions({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.aiSessions,
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      if (response.statusCode == 200) {
        return PaginatedChatSessionList.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 503) {
        throw AIAssistantUnavailableException();
      }
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load chat sessions.',
      );
      debugPrint('[AI_REPO] Error loading sessions: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[AI_REPO] Unexpected error: $e');
      return null;
    }
  }

  /// Create a new chat session
  Future<ChatSession?> createSession({
    String language = 'en',
    String title = 'New Chat',
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.aiSessions,
        data: {'language': language, 'title': title},
      );

      if (response.statusCode == 201) {
        return ChatSession.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 503) {
        throw AIAssistantUnavailableException();
      }
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to create chat session.',
      );
      debugPrint('[AI_REPO] Error creating session: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[AI_REPO] Unexpected error: $e');
      return null;
    }
  }

  /// Get a single session by ID
  Future<ChatSession?> getSessionById(int id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.aiSessions}$id/');

      if (response.statusCode == 200) {
        return ChatSession.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 503) {
        throw AIAssistantUnavailableException();
      }
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get session details.',
      );
      debugPrint('[AI_REPO] Error getting session: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[AI_REPO] Unexpected error: $e');
      return null;
    }
  }

  // ==================== MESSAGES ====================

  /// Get messages for a session
  Future<PaginatedChatMessageList?> getMessages({
    required int sessionId,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.aiSessions}$sessionId/messages/',
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      if (response.statusCode == 200) {
        return PaginatedChatMessageList.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 503) {
        throw AIAssistantUnavailableException();
      }
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load messages.',
      );
      debugPrint('[AI_REPO] Error loading messages: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[AI_REPO] Unexpected error: $e');
      return null;
    }
  }

  /// Send a message to the AI
  Future<ChatMessage?> sendMessage({
    required int sessionId,
    required String content,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.aiSessions}$sessionId/messages/',
        data: {'content': content},
      );

      if (response.statusCode == 201) {
        return ChatMessage.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 503) {
        throw AIAssistantUnavailableException();
      }
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to send message.',
      );
      debugPrint('[AI_REPO] Error sending message: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[AI_REPO] Unexpected error: $e');
      return null;
    }
  }
}
