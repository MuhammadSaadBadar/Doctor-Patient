// lib/patient/features/water_intake/screens/water_intake_history_screen.dart

import 'package:doctor/patient/features/water_intake/controllers/water_intake_history_controller.dart';
import 'package:doctor/patient/features/water_intake/widgets/water_intake_history_entry.dart';
import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WaterIntakeHistoryScreen extends GetView<WaterIntakeHistoryController> {
  const WaterIntakeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: PatientTopAppBar(
        title: 'Water Intake History',
        trailingActions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colorScheme.onSurface),
            onPressed: controller.refreshData,
          ),
        ],
        onNotificationTap: () => Get.toNamed('/notifications'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.entries.isEmpty) {
          return _buildLoadingState(context);
        }

        if (controller.hasError.value && controller.entries.isEmpty) {
          return _buildErrorState(context);
        }

        if (controller.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: colorScheme.primary,
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              MediaQuery.of(context).padding.bottom + 20,
            ),
            itemCount:
                controller.sortedDateKeys.length +
                (controller.hasMoreData.value ? 1 : 0),
            itemBuilder: (context, index) {
              // Load more indicator
              if (index == controller.sortedDateKeys.length) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: controller.isLoadingMore.value
                        ? const CircularProgressIndicator()
                        : TextButton(
                            onPressed: controller.loadMore,
                            child: const Text('Load More'),
                          ),
                  ),
                );
              }

              final dateKey = controller.sortedDateKeys[index];
              final entries = controller.groupedEntries[dateKey] ?? [];
              final dailyTotal = entries.fold<int>(
                0,
                (sum, e) => sum + e.amountMl,
              );

              return WaterIntakeHistoryEntry(
                dateKey: dateKey,
                entries: entries,
                dailyTotal: dailyTotal,
                formatDate: controller.formatDate,
                formatTime: controller.formatTime,
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary.withOpacity(0.10),
                        colorScheme.primaryContainer.withOpacity(0.06),
                      ],
                    )
                  : null,
              color: !isDark
                  ? colorScheme.surfaceContainerLowest.withOpacity(0.7)
                  : null,
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

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                gradient: isDark
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary.withOpacity(0.10),
                          colorScheme.primaryContainer.withOpacity(0.06),
                        ],
                      )
                    : null,
                color: !isDark
                    ? colorScheme.primaryContainer.withOpacity(0.25)
                    : null,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_drink_rounded,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Water Intake History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start logging your water intake to see history here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
