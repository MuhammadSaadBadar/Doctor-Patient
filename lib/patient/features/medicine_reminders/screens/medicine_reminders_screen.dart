// lib/patient/features/medicine_reminders/screens/medicine_reminders_screen.dart

import 'package:doctor/patient/features/medicine_reminders/controllers/intake_log_controller.dart'
    show IntakeLogController;
import 'package:doctor/patient/features/medicine_reminders/controllers/medicine_reminder_controller.dart';
import 'package:doctor/patient/features/medicine_reminders/widgets/reminder_card.dart';
import 'package:doctor/patient/features/medicine_reminders/widgets/reminder_empty_state.dart';
import 'package:doctor/patient/features/medicine_reminders/widgets/reminder_stat_card.dart';
import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor/core/localization/translation_keys.dart';

class MedicineRemindersScreen extends GetView<MedicineReminderController> {
  const MedicineRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: PatientTopAppBar(
        title: TranslationKeys.medicineRemindersTitle.tr,
        showBackButton: true,
        trailingActions: [
          Container(
            margin: const EdgeInsetsDirectional.only(end: 8),
            child: GestureDetector(
              onTap: controller.navigateToAddReminder,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    // const SizedBox(width: 4),
                    // Text(
                    //   'Add',
                    //   style: TextStyle(
                    //     fontSize: 12,
                    //     fontWeight: FontWeight.w700,
                    //     color: colorScheme.primary,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
        onNotificationTap: () => Get.toNamed('/notifications'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.reminders.isEmpty) {
          return _buildLoadingState(context);
        }

        if (controller.hasError.value && controller.reminders.isEmpty) {
          return _buildErrorState(context);
        }

        if (controller.isEmpty) {
          return ReminderEmptyState(onAddTap: controller.navigateToAddReminder);
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
                  // Quick Stats
                  _buildStatsRow(context),
                  const SizedBox(height: 16),

                  // Section Title
                  _buildSectionHeader(context),
                  const SizedBox(height: 12),

                  // Reminder List
                  _buildReminderList(context),

                  // Footer
                  _buildListFooter(context),
                ],
              ),
            ),
          ),
        );
      }),
      floatingActionButton: _buildFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: ReminderStatCard(
            value: '${controller.activeCount}',
            label: TranslationKeys.medicineActive.tr,
            icon: Icons.medication_rounded,
            iconColor: colorScheme.primary,
            backgroundColor: colorScheme.primary.withOpacity(0.1),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ReminderStatCard(
            value: '${controller.todayDoses}',
            label: TranslationKeys.medicineToday.tr,
            icon: Icons.schedule_rounded,
            iconColor: colorScheme.secondary,
            backgroundColor: colorScheme.secondary.withOpacity(0.1),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ReminderStatCard(
            value: '${controller.overallAdherence.toInt()}%',
            label: TranslationKeys.medicineAdherence.tr,
            icon: Icons.monitor_rounded,
            iconColor: colorScheme.tertiary,
            backgroundColor: colorScheme.tertiary.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          TranslationKeys.medicineYourSchedule.tr,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            fontFamily: 'PlayfairDisplay',
          ),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                '${TranslationKeys.medicineAll.tr} (${controller.reminders.length})',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReminderList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: controller.reminders.map((reminder) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: ReminderCard(
            reminder: reminder,
            onToggle: () => controller.toggleReminder(reminder),
            onEdit: () => controller.navigateToEditReminder(reminder),
            onDelete: () => controller.deleteReminder(reminder),
            onTap: () => controller.navigateToReminderDetail(reminder.id),
            onTakeNow: () {
              // Find the intake log controller and log intake
              if (Get.isRegistered<IntakeLogController>()) {
                final intakeController = Get.find<IntakeLogController>();
                // Use current time as scheduled_for for immediate intake
                intakeController.logIntake(
                  reminderId: reminder.id,
                  status: 'taken',
                  scheduledFor: DateTime.now(),
                );
              }
            },
            onSkipNow: () {
              if (Get.isRegistered<IntakeLogController>()) {
                final intakeController = Get.find<IntakeLogController>();
                intakeController.logIntake(
                  reminderId: reminder.id,
                  status: 'skipped',
                  scheduledFor: DateTime.now(),
                );
              }
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildListFooter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: colorScheme.tertiary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            TranslationKeys.medicineShowingActive.tr.replaceAll('@count', '${controller.reminders.length}'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton.extended(
      onPressed: controller.navigateToAddReminder,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      icon: Icon(Icons.add_rounded, size: 22),
      label: Text(
        TranslationKeys.medicineAddReminder.tr,
        style: const TextStyle(fontWeight: FontWeight.w600),
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
            TranslationKeys.medicineLoading.tr,
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
              child: Text(TranslationKeys.commonTryAgain.tr),
            ),
          ],
        ),
      ),
    );
  }
}
