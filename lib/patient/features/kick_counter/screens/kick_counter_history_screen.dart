// lib/patient/features/kick_counter/screens/kick_history_screen.dart

import 'package:doctor/patient/features/kick_counter/controllers/kick_history_controller.dart';
import 'package:doctor/patient/features/kick_counter/widgets/kick_daily_summary_card.dart';
import 'package:doctor/patient/features/kick_counter/widgets/kick_empty_state.dart';
import 'package:doctor/patient/features/kick_counter/widgets/kick_session_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KickHistoryScreen extends GetView<KickHistoryController> {
  const KickHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Kick History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
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
                  16, 16, 16, MediaQuery.of(context).padding.bottom + 20),
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
      count += 1; // Daily summary card
      final sessions = controller.getSessionsForDate(summary.date);
      count += sessions.length; // Session items
    }

    // Load more indicator
    if (controller.hasMoreData.value) {
      count += 1;
    }

    return count;
  }

  Widget _buildItemAtIndex(int index, BuildContext context) {
    final summaries = controller.dailySummaries;
    int currentIndex = 0;

    for (final summary in summaries) {
      // Daily Summary Card
      if (index == currentIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: KickDailySummaryCard(
            summary: summary,
            onTap: null, // Could expand to show sessions
          ),
        );
      }
      currentIndex++;

      // Session Items for this day
      final sessions = controller.getSessionsForDate(summary.date);
      for (final session in sessions) {
        if (index == currentIndex) {
          return Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4, right: 16),
            child: KickSessionItem(
              session: session,
              onTap: () => controller.navigateToSessionDetail(session.id),
            ),
          );
        }
        currentIndex++;
      }
    }

    // Load more indicator
    if (controller.hasMoreData.value && index == currentIndex) {
      return _buildLoadMoreIndicator(context);
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadMoreIndicator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: controller.isLoadingMore.value
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: colorScheme.primary,
                  strokeWidth: 2.5,
                ),
              )
            : const SizedBox.shrink(),
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
            'Loading history...',
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
              'Something went wrong',
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
              onPressed: controller.refreshData,
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
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
