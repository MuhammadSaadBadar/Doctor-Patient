// lib/patient/features/medicine_reminders/screens/intake_log_screen.dart

import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:doctor/patient/features/medicine_reminders/controllers/intake_log_controller.dart';
import 'package:doctor/patient/features/medicine_reminders/controllers/medicine_reminder_controller.dart';
import 'package:doctor/patient/features/medicine_reminders/widgets/intake_log_entry.dart';
import 'package:doctor/patient/features/medicine_reminders/widgets/intake_log_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IntakeLogScreen extends GetView<IntakeLogController> {
  const IntakeLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: PatientTopAppBar(
        title: 'Adherence History',
        trailingActions: [
          IconButton(
            icon: Icon(Icons.filter_list_rounded, color: colorScheme.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.logs.isEmpty) {
          return _buildLoadingState(context);
        }

        if (controller.hasError.value && controller.logs.isEmpty) {
          return _buildErrorState(context);
        }

        if (controller.isEmpty) {
          return _buildEmptyState(context);
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
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              child: Column(
                children: [
                  // Filter & View Toggle
                  _buildFilterBar(context),
                  const SizedBox(height: 16),

                  // Summary Stats
                  Obx(
                    () => IntakeLogSummaryCard(
                      taken: controller.takenCount,
                      skipped: controller.skippedCount,
                      pending: controller.pendingCount,
                      adherenceRate: controller.adherenceRate,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // List View
                  _buildListView(context),

                  // Calendar View (hidden by default)
                  _buildCalendarView(context),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // View Toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Adherence Records',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Obx(
              () => Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    _buildViewToggleButton(
                      context,
                      label: 'List View',
                      value: 'list',
                      isSelected: controller.viewType.value == 'list',
                    ),
                    _buildViewToggleButton(
                      context,
                      label: 'Calendar',
                      value: 'calendar',
                      isSelected: controller.viewType.value == 'calendar',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Reminder Filter
        Obx(() {
          if (!Get.isRegistered<MedicineReminderController>()) {
            return const SizedBox.shrink();
          }
          final reminderController = Get.find<MedicineReminderController>();
          if (reminderController.reminders.isEmpty) {
            return const SizedBox.shrink();
          }
          return Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.medication_rounded,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: Obx(
                      () => DropdownButton<int?>(
                        value: controller.selectedReminderId.value,
                        isExpanded: true,
                        hint: Text(
                          'All Medications',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        items: [
                          DropdownMenuItem<int?>(
                            value: null,
                            child: Text(
                              'All Medications',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          ...reminderController.reminders.map((reminder) {
                            return DropdownMenuItem<int?>(
                              value: reminder.id,
                              child: Text(
                                reminder.medicineName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          controller.setReminderFilter(value);
                        },
                        dropdownColor: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (controller.selectedReminderId.value != null)
                  GestureDetector(
                    onTap: () => controller.setReminderFilter(null),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),

        // Date Range Chips
        Obx(
          () => Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildDateChip(context, label: 'Today', value: 'today'),
                _buildDateChip(context, label: 'This Week', value: 'week'),
                _buildDateChip(context, label: 'This Month', value: 'month'),
                _buildDateChip(context, label: 'Custom', value: 'custom'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewToggleButton(
    BuildContext context, {
    required String label,
    required String value,
    required bool isSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => controller.setViewType(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildDateChip(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = controller.selectedDateRange.value == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setDateRange(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      if (controller.viewType.value == 'calendar') {
        return const SizedBox.shrink();
      }

      final groupedLogs = controller.groupedLogs;
      final dateKeys = controller.sortedDateKeys;

      if (dateKeys.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(
              'No records found',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }

      return Column(
        children: dateKeys.map((dateKey) {
          final logsForDate = groupedLogs[dateKey] ?? [];
          final takenCount = logsForDate.where((l) => l.isTaken).length;
          final totalCount = logsForDate.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.formatDate(dateKey),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        fontFamily: 'PlayfairDisplay',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        '$takenCount/$totalCount doses taken',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Log Entries
              Column(
                children: logsForDate.map((log) {
                  // Look up medicine name from reminder controller
                  String medicineName = 'Unknown Medicine';
                  if (Get.isRegistered<MedicineReminderController>()) {
                    final reminderController = Get.find<MedicineReminderController>();
                    final reminder = reminderController.reminders
                        .firstWhereOrNull((r) => r.id == log.reminderId);
                    if (reminder != null) {
                      medicineName = reminder.medicineName;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: IntakeLogEntry(
                      log: log,
                      medicineName: medicineName,
                      onTakeNow: log.isPending
                          ? () {
                              controller.logIntake(
                                reminderId: log.reminderId,
                                status: 'taken',
                                scheduledFor: log.scheduledFor,
                              );
                            }
                          : null,
                      onSkipNow: log.isPending
                          ? () {
                              controller.logIntake(
                                reminderId: log.reminderId,
                                status: 'skipped',
                                scheduledFor: log.scheduledFor,
                              );
                            }
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        }).toList(),
      );
    });
  }

  Widget _buildCalendarView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return Obx(() {
      if (controller.viewType.value == 'list') {
        return const SizedBox.shrink();
      }

      // Get the current month being viewed (default to current month)
      final currentMonth = DateTime(now.year, now.month);

      // Build adherence map for quick lookup
      final adherenceMap = <String, Map<String, int>>{};
      for (final log in controller.logs) {
        final dateKey = log.scheduledFor.toIso8601String().split('T')[0];
        if (!adherenceMap.containsKey(dateKey)) {
          adherenceMap[dateKey] = {'taken': 0, 'skipped': 0, 'pending': 0};
        }
        if (log.isTaken)
          adherenceMap[dateKey]!['taken'] =
              adherenceMap[dateKey]!['taken']! + 1;
        if (log.isSkipped)
          adherenceMap[dateKey]!['skipped'] =
              adherenceMap[dateKey]!['skipped']! + 1;
        if (log.isPending)
          adherenceMap[dateKey]!['pending'] =
              adherenceMap[dateKey]!['pending']! + 1;
      }

      // Get first day of month and number of days
      final firstDayOfMonth = DateTime(
        currentMonth.year,
        currentMonth.month,
        1,
      );
      final lastDayOfMonth = DateTime(
        currentMonth.year,
        currentMonth.month + 1,
        0,
      );
      final daysInMonth = lastDayOfMonth.day;
      final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Calendar Header with Month Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    color: colorScheme.primary,
                  ),
                  onPressed: () {
                    // TODO: Implement month navigation
                  },
                ),
                Text(
                  '${months[currentMonth.month - 1]} ${currentMonth.year}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    fontFamily: 'PlayfairDisplay',
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.primary,
                  ),
                  onPressed: () {
                    // TODO: Implement month navigation
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Weekday Headers
            Row(
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((
                day,
              ) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),

            // Calendar Grid
            ...List.generate((daysInMonth + firstWeekday - 1) ~/ 7 + 1, (
              weekIndex,
            ) {
              return Row(
                children: List.generate(7, (dayIndex) {
                  final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 2;
                  final isCurrentMonth =
                      dayNumber >= 1 && dayNumber <= daysInMonth;
                  final isToday =
                      isCurrentMonth &&
                      dayNumber == now.day &&
                      currentMonth.month == now.month &&
                      currentMonth.year == now.year;

                  if (!isCurrentMonth) {
                    return Expanded(child: Container(height: 48));
                  }

                  final dateKey = DateTime(
                    currentMonth.year,
                    currentMonth.month,
                    dayNumber,
                  ).toIso8601String().split('T')[0];
                  final dayAdherence = adherenceMap[dateKey];

                  Color? dayColor;
                  if (dayAdherence != null) {
                    final total =
                        (dayAdherence['taken'] ?? 0) +
                        (dayAdherence['skipped'] ?? 0) +
                        (dayAdherence['pending'] ?? 0);
                    if (total > 0) {
                      final takenPct = (dayAdherence['taken'] ?? 0) / total;
                      if (takenPct >= 0.8) {
                        dayColor = Colors.green;
                      } else if (takenPct >= 0.5) {
                        dayColor = Colors.orange;
                      } else {
                        dayColor = Colors.red;
                      }
                    }
                  }

                  return Expanded(
                    child: Container(
                      height: 48,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isToday
                            ? colorScheme.primary.withOpacity(0.15)
                            : dayColor?.withOpacity(0.15) ?? Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isToday
                            ? Border.all(color: colorScheme.primary, width: 2)
                            : null,
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              '$dayNumber',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isToday
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isToday
                                    ? colorScheme.primary
                                    : (dayColor ?? colorScheme.onSurface),
                              ),
                            ),
                          ),
                          if (dayAdherence != null &&
                              ((dayAdherence['taken'] ?? 0) > 0 ||
                                  (dayAdherence['skipped'] ?? 0) > 0))
                            Positioned(
                              bottom: 4,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if ((dayAdherence['taken'] ?? 0) > 0)
                                    Container(
                                      width: 6,
                                      height: 6,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 1,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  if ((dayAdherence['skipped'] ?? 0) > 0)
                                    Container(
                                      width: 6,
                                      height: 6,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 1,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: Colors.orange,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  if ((dayAdherence['pending'] ?? 0) > 0)
                                    Container(
                                      width: 6,
                                      height: 6,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.error,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            }),

            const SizedBox(height: 16),

            // Legend
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildLegendItem(
                  context,
                  color: Colors.green,
                  label: 'Good (≥80%)',
                ),
                _buildLegendItem(
                  context,
                  color: Colors.orange,
                  label: 'Fair (50-79%)',
                ),
                _buildLegendItem(
                  context,
                  color: Colors.red,
                  label: 'Poor (<50%)',
                ),
                _buildLegendItem(
                  context,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                  label: 'No Data',
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLegendItem(
    BuildContext context, {
    required Color color,
    required String label,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medication_rounded,
                size: 32,
                color: colorScheme.primary.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No intake records yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                fontFamily: 'PlayfairDisplay',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start taking your medicines to track adherence and keep you and baby healthy.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.toNamed('/medicine-reminders/add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
              child: const Text('Add Medication'),
            ),
          ],
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
              color: colorScheme.primaryContainer.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading records...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
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
                color: colorScheme.errorContainer.withOpacity(0.3),
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
