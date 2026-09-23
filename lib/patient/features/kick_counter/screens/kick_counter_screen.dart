// lib/patient/features/kick_counter/screens/kick_counter_screen.dart

import 'package:doctor/core/localization/translation_keys.dart';
import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:doctor/patient/features/kick_counter/controllers/kick_counter_controller.dart';
import 'package:doctor/patient/features/kick_counter/widgets/kick_counter_display.dart';
import 'package:doctor/patient/features/kick_counter/widgets/kick_history_item.dart';
import 'package:doctor/patient/features/kick_counter/widgets/kick_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KickCounterScreen extends GetView<KickCounterController> {
  const KickCounterScreen({super.key});

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // ✅ surface, not deprecated background
      backgroundColor: colorScheme.background,
      appBar: PatientTopAppBar(
        title: TranslationKeys.kickCounterTitle.tr,
        onNotificationTap: () => Get.toNamed('/notifications'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.allSessions.isEmpty) {
          return _buildLoadingState(context);
        }

        if (controller.hasError.value && controller.allSessions.isEmpty) {
          return _buildErrorState(context);
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              MediaQuery.of(context).padding.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTitleSection(context),
                const SizedBox(height: 24),
                Obx(
                  () => KickCounterDisplay(
                    kickCount: controller.activeSession.value?.kickCount ?? 0,
                    onAdd: controller.recordKick,
                    onRemove: () {
                      Get.snackbar(
                        TranslationKeys.kickCounterInfo.tr,
                        TranslationKeys.kickCounterRemoveComingSoon.tr,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    isActive: controller.activeSession.value != null,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => KickStatusBadge(
                    isActive: controller.activeSession.value != null,
                    kickCount: controller.activeSession.value?.kickCount,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  if (controller.isSessionActive) {
                    return _buildEndSessionButton(context);
                  }
                  return _buildStartSessionButton(context);
                }),
                const SizedBox(height: 16),
                _buildHistorySection(context),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          TranslationKeys.kickCounterTitle.tr,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          TranslationKeys.kickCounterNoSessionsDesc.tr,
          style: TextStyle(fontSize: 16, color: cs.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildStartSessionButton(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isProcessing.value
            ? null
            : controller.startSession,
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          disabledBackgroundColor: cs.onSurface.withOpacity(0.12),
          disabledForegroundColor: cs.onSurface.withOpacity(0.38),
        ),
        child: controller.isProcessing.value
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: cs.onPrimary,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                TranslationKeys.kickCounterStart.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildEndSessionButton(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: controller.isProcessing.value ? null : controller.endSession,
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.error,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: cs.error.withOpacity(0.5)),
        ),
        child: controller.isProcessing.value
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: cs.error,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stop_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    TranslationKeys.kickCounterEnd.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    final sessions = controller.allSessions;
    final displaySessions = sessions.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ✅ Gradient in dark, solid in light
        gradient: isDark
            ? LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [
                  cs.primary.withOpacity(0.10),
                  cs.primaryContainer.withOpacity(0.06),
                ],
              )
            : null,
        color: !isDark ? cs.surfaceContainerLowest : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? cs.primary.withOpacity(0.12)
              : cs.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: cs.shadow.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.history_rounded, size: 20, color: cs.secondary),
                  const SizedBox(width: 8),
                  Text(
                    TranslationKeys.kickCounterRecentHistory.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: controller.navigateToHistory,
                style: TextButton.styleFrom(foregroundColor: cs.primary),
                child: Text(TranslationKeys.kickCounterViewAll.tr),
              ),
            ],
          ),
          if (displaySessions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  TranslationKeys.kickCounterNoSessions.tr,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
            )
          else
            Column(
              children: displaySessions.map((session) {
                return KickHistoryItem(session: session);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(isDark ? 0.35 : 0.2),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(color: cs.primary, strokeWidth: 3),
          ),
          const SizedBox(height: 16),
          Text(
            TranslationKeys.commonLoading.tr,
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
                color: cs.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: cs.onErrorContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              TranslationKeys.commonSomethingWentWrong.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
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
}
