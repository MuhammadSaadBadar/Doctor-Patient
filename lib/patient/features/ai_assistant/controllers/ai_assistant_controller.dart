// lib/patient/features/ai_assistant/controllers/ai_assistant_controller.dart

import 'package:doctor/core/network/api_exceptions.dart';
import 'package:doctor/patient/features/ai_assistant/models/chat_message.dart';
import 'package:doctor/patient/features/ai_assistant/models/chat_session.dart';
import 'package:doctor/patient/features/ai_assistant/repositories/ai_assistant_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AIAssistantController extends GetxController {
  late final AIAssistantRepository _repository;

  // State
  final isLoading = false.obs;
  final isLoadingMessages = false.obs;
  final isSending = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Data
  final currentSession = Rx<ChatSession?>(null);
  final messages = <ChatMessage>[].obs;
  final sessions = <ChatSession>[].obs;

  // Typing indicator
  final isTyping = false.obs;

  // Input
  final messageController = TextEditingController();
  final focusNode = FocusNode();
  final inputText = ''.obs;

  // Computed getters
  bool get hasMessages => messages.isNotEmpty;
  bool get hasSessions => sessions.isNotEmpty;
  bool get isSessionActive => currentSession.value != null;
  String get sessionTitle => currentSession.value?.title ?? 'AI Assistant';

  // Flag to track if this is the first exchange in a new session
  bool _isFirstExchange = false;

  // Temporary message ID counter for optimistic updates
  int _tempMessageId = -1;
  int _getNextTempId() => _tempMessageId--;

  @override
  void onInit() {
    super.onInit();
    _repository = Get.find<AIAssistantRepository>();
    messageController.addListener(() {
      inputText.value = messageController.text;
    });
    loadSessions();
  }

  @override
  void onClose() {
    messageController.dispose();
    focusNode.dispose();
    super.onClose();
  }

  Future<void> loadSessions() async {
    try {
      final result = await _repository.getSessions(page: 1, pageSize: 50);
      if (result != null) {
        sessions.value = result.results;
        debugPrint('[AI] Loaded ${sessions.length} sessions');
        if (sessions.isNotEmpty) {
          switchSession(sessions.first.id);
        }
      }
    } on AIAssistantUnavailableException {
      _showServiceUnavailableError();
    } catch (e) {
      debugPrint('[AI] Error loading sessions: $e');
    }
  }

  Future<void> createNewSession() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final session = await _repository.createSession(
        language: 'en',
        title: 'New Chat',
      );

      if (session != null) {
        currentSession.value = session;
        sessions.insert(0, session);
        messages.clear();
        debugPrint('[AI] Created new session: ${session.id}');
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to create chat session. Please try again.';
      }
    } on AIAssistantUnavailableException {
      _showServiceUnavailableError();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Something went wrong. Please try again.';
      debugPrint('[AI] Error creating session: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMessages(int sessionId) async {
    if (isLoadingMessages.value) return;

    isLoadingMessages.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await _repository.getMessages(
        sessionId: sessionId,
        page: 1,
        pageSize: 50,
      );

      if (result != null) {
        messages.value = result.results;
        debugPrint('[AI] Loaded ${messages.length} messages');
        _scrollToBottom();
      }
    } on AIAssistantUnavailableException {
      _showServiceUnavailableError();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load messages. Please try again.';
      debugPrint('[AI] Error loading messages: $e');
    } finally {
      isLoadingMessages.value = false;
    }
  }

  Future<void> sendMessage() async {
    final content = messageController.text.trim();
    if (content.isEmpty || isSending.value) return;

    isSending.value = true;

    if (currentSession.value == null) {
      try {
        final session = await _repository.createSession(
          language: 'en',
          title: 'New Chat',
        );
        if (session != null) {
          currentSession.value = session;
          sessions.insert(0, session);
          messages.clear();
        } else {
          _showErrorSnackbar('Failed to create chat session.');
          isSending.value = false;
          return;
        }
      } catch (e) {
        _showErrorSnackbar('Something went wrong creating a session.');
        isSending.value = false;
        return;
      }
    }

    _isFirstExchange = messages.isEmpty;
    final tempId = _getNextTempId();

    final userMessage = ChatMessage(
      id: tempId,
      role: 'user',
      content: content,
      createdAt: DateTime.now(),
    );
    messages.add(userMessage);
    messageController.clear();
    isTyping.value = true;

    _scrollToBottom();

    try {
      final response = await _repository.sendMessage(
        sessionId: currentSession.value!.id,
        content: content,
      );

      isTyping.value = false;

      if (response != null) {
        messages.removeWhere((m) => m.id == tempId);
        messages.add(response);

        if (_isFirstExchange) {
          final newTitle = content.length > 30
              ? '${content.substring(0, 30)}...'
              : content;
          currentSession.value = currentSession.value?.copyWith(title: newTitle);

          final sessionIndex = sessions.indexWhere(
            (s) => s.id == currentSession.value?.id,
          );
          if (sessionIndex != -1) {
            sessions[sessionIndex] = currentSession.value!;
          }
        }
        debugPrint('[AI] AI response received');
      } else {
        messages.removeWhere((m) => m.id == tempId);
        _showErrorSnackbar('Failed to get AI response. Please try again.');
      }
    } on AIAssistantUnavailableException {
      messages.removeWhere((m) => m.id == tempId);
      isTyping.value = false;
      _showServiceUnavailableError();
    } catch (e) {
      messages.removeWhere((m) => m.id == tempId);
      isTyping.value = false;
      _showErrorSnackbar('Something went wrong. Please try again.');
      debugPrint('[AI] Error sending message: $e');
    } finally {
      isSending.value = false;
      _scrollToBottom();
    }
  }

  void switchSession(int sessionId) {
    final session = sessions.firstWhereOrNull((s) => s.id == sessionId);
    if (session != null) {
      currentSession.value = session;
      loadMessages(sessionId);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  void clearInput() {
    messageController.clear();
  }

  bool get canSend =>
      inputText.value.trim().isNotEmpty && !isSending.value;

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _showServiceUnavailableError() {
    hasError.value = true;
    errorMessage.value =
        'AI Assistant is temporarily unavailable. Please try again later.';
  }

  void retry() {
    hasError.value = false;
    errorMessage.value = '';
    if (currentSession.value != null) {
      loadMessages(currentSession.value!.id);
    } else {
      createNewSession();
    }
  }
}