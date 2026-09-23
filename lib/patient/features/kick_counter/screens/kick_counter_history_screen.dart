// lib/patient/features/kick_counter/screens/kick_history_screen.dart

import 'package:doctor/core/localization/translation_keys.dart';
import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:doctor/patient/features/kick_counter/controllers/kick_history_controller.dart';
import 'package:doctor/patient/features/kick_counter/widgets/kick_daily_summary_card.dart';
import 'package:doctor/patient/features/kick_counter/widgets/kick_empty_state.dart';
import 'package:doctor/patient/features/kick_counter/widgets/kick_session_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KickHistoryScreen extends GetView<KickHistoryController> {
  const KickHistoryScreen({super.key});

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // ✅ surface, not deprecated background
      backgroundColor: colorScheme.background,
      appBar: PatientTopAppBar(
        title: TranslationKeys.kickCounterHistory.tr,
        trailingActions: [
          IconButton(
            icon: Icon(Icons.child_care_rounded, color: colorScheme.primary),
            onPressed: () => Get.toNamed('/kick-counter'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.allSessions.isEmpty) {
          return _buildLoadingState(context);
        }

        if (controller.hasError.value && controller.allSessions.isEmpty) {
          return _buildErrorState(context);
        }

        if (controller.isEmpty) {
          return KickEmptyState(
            onActionTap: () => Get.toNamed('/kick-counter'),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: colorScheme.primary,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification) {
                final metrics = notification.metrics;
                if (metrics.pixels >= metrics.maxScrollExtent - 200) {
                  controller.loadMore();
                }
              }
              return false;
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).padding.bottom + 20,
              ),
              itemCount: _getTotalItemCount(),
              itemBuilder: (context, index) {
                return _buildItemAtIndex(index, context);
              },
            ),
          ),
        );
      }),
    );
  }

  int _getTotalItemCount() {
    final summaries = controller.dailySummaries;
    int count = 0;
    for (final summary in summaries) {
      count += 1;
      final sessions = controller.getSessionsForDate(summary.date);
      count += sessions.length;
    }
    if (controller.hasMoreData.value) count += 1;
    return count;
  }

  Widget _buildItemAtIndex(int index, BuildContext context) {
    final summaries = controller.dailySummaries;
    int currentIndex = 0;

    for (final summary in summaries) {
      if (index == currentIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: KickDailySummaryCard(summary: summary, onTap: null),
        );
      }
      currentIndex++;

      final sessions = controller.getSessionsForDate(summary.date);
      for (final session in sessions) {
        if (index == currentIndex) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 16,
              bottom: 4,
              end: 16,
            ),
            child: KickSessionItem(
              session: session,
              onTap: () => controller.navigateToSessionDetail(session.id),
            ),
          );
        }
        currentIndex++;
      }
    }

    if (controller.hasMoreData.value && index == currentIndex) {
      return _buildLoadMoreIndicator(context);
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadMoreIndicator(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: controller.isLoadingMore.value
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: cs.primary,
                  strokeWidth: 2.5,
                ),
              )
            : const SizedBox.shrink(),
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
              // ✅ Stronger in dark
              color: cs.primaryContainer.withOpacity(isDark ? 0.35 : 0.2),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(color: cs.primary, strokeWidth: 3),
          ),
          const SizedBox(height: 16),
          Text(
            TranslationKeys.kickCounterLoadingHistory.tr,
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
                // ✅ Correct contrast pair
                color: cs.onErrorContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
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
