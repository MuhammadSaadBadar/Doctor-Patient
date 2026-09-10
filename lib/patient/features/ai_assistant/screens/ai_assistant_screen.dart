// lib/patient/features/ai_assistant/screens/ai_assistant_screen.dart

import 'package:doctor/patient/features/ai_assistant/controllers/ai_assistant_controller.dart';
import 'package:doctor/patient/features/ai_assistant/widgets/chat_bubble.dart';
import 'package:doctor/patient/features/ai_assistant/widgets/typing_indicator.dart';
import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor/core/localization/translation_keys.dart';

class AIAssistantScreen extends GetView<AIAssistantController> {
  const AIAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: _buildAppBar(context),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState(context);
        }

        if (controller.hasError.value && controller.messages.isEmpty) {
          return _buildErrorState(context);
        }

        return _buildChatMessages(context);
      }),
      bottomNavigationBar: _buildInputArea(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PatientTopAppBar(
      title: controller.sessionTitle,
      showBackButton: true,
      customTitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            controller.sessionTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                TranslationKeys.aiOnline.tr,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
      customActions: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: colorScheme.primary.withOpacity(0.1),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 16,
              color: colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildChatMessages(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingMessages.value && controller.messages.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.messages.isEmpty) {
        return _buildEmptyState(context);
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount:
            controller.messages.length + (controller.isTyping.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == controller.messages.length &&
              controller.isTyping.value) {
            return const TypingIndicator();
          }
          return ChatBubble(message: controller.messages[index]);
        },
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              TranslationKeys.aiStartConversation.tr,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              TranslationKeys.aiAskAnything.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.add_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => _showNewSessionDialog(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: controller.messageController,
                    focusNode: controller.focusNode,
                    onSubmitted: (_) => controller.sendMessage(),
                    decoration: InputDecoration(
                      hintText: TranslationKeys.aiTypeMessage.tr,
                      hintStyle: TextStyle(color: colorScheme.outline),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                () => Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: controller.canSend
                        ? colorScheme.primary
                        : colorScheme.primary.withOpacity(0.3),
                    shape: BoxShape.circle,
                    boxShadow: controller.canSend
                        ? [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: IconButton(
                    icon: controller.isSending.value
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: colorScheme.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            Icons.send_rounded,
                            color: controller.canSend
                                ? colorScheme.onPrimary
                                : colorScheme.onPrimary.withOpacity(0.5),
                          ),
                    onPressed: controller.canSend
                        ? controller.sendMessage
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading...',
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              TranslationKeys.commonSomethingWentWrong.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.retry,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(TranslationKeys.commonTryAgain.tr),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewSessionDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                Icons.add_circle_rounded,
                color: colorScheme.primary,
              ),
              title: Text(TranslationKeys.aiNewChat.tr),
              onTap: () {
                Get.back();
                controller.createNewSession();
              },
            ),
            if (controller.hasSessions) ...[
              const Divider(),
              ListTile(
                leading: Icon(
                  Icons.history_rounded,
                  color: colorScheme.secondary,
                ),
                title: Text(TranslationKeys.aiRecentChats.tr),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                onTap: () {
                  Get.back();
                  _showSessionsDialog(context);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSessionsDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              TranslationKeys.aiRecentChats.tr,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: Obx(() {
                if (controller.sessions.isEmpty) {
                  return Center(
                    child: Text(
                      TranslationKeys.aiNoRecentChats.tr,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.sessions.length,
                  itemBuilder: (context, index) {
                    final session = controller.sessions[index];
                    final isActive =
                        controller.currentSession.value?.id == session.id;
                    return ListTile(
                      leading: Icon(
                        Icons.chat_rounded,
                        color: isActive
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                      title: Text(
                        session.title,
                        style: TextStyle(
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isActive
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        session.formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: isActive
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: colorScheme.primary,
                              size: 16,
                            )
                          : null,
                      onTap: () {
                        Get.back();
                        if (!isActive) {
                          controller.switchSession(session.id);
                        }
                      },
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.back();
                controller.createNewSession();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(TranslationKeys.aiPlusNewChat.tr),
            ),
          ],
        ),
      ),
    );
  }
}
