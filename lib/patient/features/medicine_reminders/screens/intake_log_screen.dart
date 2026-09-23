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

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _semanticFg(BuildContext context, Color base) {
    final isDark = _isDark(context);
    if (base == Colors.green)
      return isDark ? Colors.green.shade300 : Colors.green.shade800;
    if (base == Colors.orange)
      return isDark ? Colors.orange.shade300 : Colors.orange.shade800;
    if (base == Colors.red)
      return isDark ? Colors.red.shade300 : Colors.red.shade800;
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      // ✅ surface, not deprecated background
      backgroundColor: cs.background,
      appBar: PatientTopAppBar(
        title: 'Adherence History',
        trailingActions: [
          IconButton(
            icon: Icon(Icons.filter_list_rounded, color: cs.primary),
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
          color: cs.primary,
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
                  _buildFilterBar(context),
                  const SizedBox(height: 16),
                  Obx(
                    () => IntakeLogSummaryCard(
                      taken: controller.takenCount,
                      skipped: controller.skippedCount,
                      pending: controller.pendingCount,
                      adherenceRate: controller.adherenceRate,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildListView(context),
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
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.filter_list_rounded, size: 20, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'Adherence Records',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Obx(
              () => Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  // ✅ Slightly stronger in dark
                  color: isDark
                      ? cs.primary.withOpacity(0.10)
                      : cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(30),
                  border: isDark
                      ? Border.all(
                          color: cs.primary.withOpacity(0.15),
                          width: 1,
                        )
                      : null,
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
              // ✅ Gradient tint in dark
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
              color: !isDark ? cs.surfaceContainer : null,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isDark
                    ? cs.primary.withOpacity(0.15)
                    : cs.outlineVariant.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.medication_rounded,
                  size: 18,
                  color: cs.onSurfaceVariant,
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
                            color: cs.onSurfaceVariant,
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
                                color: cs.onSurface,
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
                                  color: cs.onSurface,
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          controller.setReminderFilter(value);
                        },
                        // ✅ surfaceContainerHigh reads correctly in both themes
                        dropdownColor: isDark
                            ? cs.surfaceContainerHigh
                            : cs.surface,
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
                      color: cs.onSurfaceVariant,
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
              // ✅ Gradient in dark
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
              border: isDark
                  ? Border.all(color: cs.primary.withOpacity(0.12), width: 1)
                  : null,
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
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => controller.setViewType(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: cs.primary.withOpacity(0.2),
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
            color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
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
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);
    final isSelected = controller.selectedDateRange.value == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setDateRange(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? cs.primary.withOpacity(isDark ? 0.22 : 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSelected ? cs.primary : cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

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
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
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
                        color: cs.onSurface,
                        fontFamily: 'PlayfairDisplay',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        // ✅ Stronger in dark
                        color: cs.primary.withOpacity(isDark ? 0.20 : 0.10),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        '$takenCount/$totalCount doses taken',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: logsForDate.map((log) {
                  String medicineName = 'Unknown Medicine';
                  if (Get.isRegistered<MedicineReminderController>()) {
                    final reminderController =
                        Get.find<MedicineReminderController>();
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
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);
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

      final currentMonth = DateTime(now.year, now.month);

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
      final firstWeekday = firstDayOfMonth.weekday;

      // Semantic hues
      final greenFg = _semanticFg(context, Colors.green);
      final orangeFg = _semanticFg(context, Colors.orange);
      final redFg = _semanticFg(context, Colors.red);

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // ✅ Gradient in dark
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left_rounded, color: cs.primary),
                  onPressed: () {},
                ),
                Text(
                  '${months[currentMonth.month - 1]} ${currentMonth.year}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                    fontFamily: 'PlayfairDisplay',
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right_rounded, color: cs.primary),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
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

                  // ✅ Use semantic foreground colors, not raw hues
                  Color? dayColor;
                  if (dayAdherence != null) {
                    final total =
                        (dayAdherence['taken'] ?? 0) +
                        (dayAdherence['skipped'] ?? 0) +
                        (dayAdherence['pending'] ?? 0);
                    if (total > 0) {
                      final takenPct = (dayAdherence['taken'] ?? 0) / total;
                      if (takenPct >= 0.8) {
                        dayColor = greenFg;
                      } else if (takenPct >= 0.5) {
                        dayColor = orangeFg;
                      } else {
                        dayColor = redFg;
                      }
                    }
                  }

                  return Expanded(
                    child: Container(
                      height: 48,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isToday
                            ? cs.primary.withOpacity(isDark ? 0.22 : 0.15)
                            : dayColor?.withOpacity(isDark ? 0.20 : 0.15) ??
                                  Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isToday
                            ? Border.all(color: cs.primary, width: 2)
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
                                    ? cs.primary
                                    : (dayColor ?? cs.onSurface),
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
                                      decoration: BoxDecoration(
                                        color: greenFg,
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
                                      decoration: BoxDecoration(
                                        color: orangeFg,
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
                                        color: cs.error,
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
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildLegendItem(context, color: greenFg, label: 'Good (≥80%)'),
                _buildLegendItem(
                  context,
                  color: orangeFg,
                  label: 'Fair (50-79%)',
                ),
                _buildLegendItem(context, color: redFg, label: 'Poor (<50%)'),
                _buildLegendItem(
                  context,
                  color: cs.onSurfaceVariant.withOpacity(0.3),
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
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                // ✅ Stronger in dark
                color: cs.primary.withOpacity(isDark ? 0.18 : 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medication_rounded,
                size: 32,
                color: cs.primary.withOpacity(isDark ? 0.7 : 0.4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No intake records yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
                fontFamily: 'PlayfairDisplay',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start taking your medicines to track adherence and keep you and baby healthy.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.toNamed('/medicine-reminders/add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
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
              color: cs.primaryContainer.withOpacity(isDark ? 0.35 : 0.15),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(color: cs.primary, strokeWidth: 3),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading records...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: cs.onSurfaceVariant,
            ),
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
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
