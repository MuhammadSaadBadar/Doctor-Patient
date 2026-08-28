// lib/features/patient/screens/medicine_reminders_screen.dart

import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/bottom_nav_bar.dart';
import 'package:doctor/core/widgets/top_app_bar.dart';
import 'package:doctor/features/patient/controllers/medicine_reminders_controller.dart';
import 'package:doctor/features/patient/models/medicine_reminder.dart';
import 'package:doctor/features/patient/widgets/medicine_reminder_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MedicineRemindersScreen extends GetView<MedicineRemindersController> {
  const MedicineRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          const TopAppNavBar.gradient(
            title: 'Medicine Reminders',
            height: 64,
            showBackButton: true,
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.reminders.isEmpty) {
                return _buildLoadingState(context);
              }

              if (controller.hasError.value) {
                return _buildErrorState(context);
              }

              return RefreshIndicator(
                onRefresh: controller.refreshData,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32.0 : 16.0,
                    vertical: 16.0,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with stats
                        _buildHeader(context),
                        const SizedBox(height: 20),
                        // Filter bar
                        _buildFilterBar(),
                        const SizedBox(height: 16),
                        // Reminders list
                        _buildRemindersList(context),
                        const SizedBox(height: 80), // Bottom padding for FAB
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
      floatingActionButton: Obx(
        () => Visibility(
          visible: !controller.isLoading.value,
          child: FloatingActionButton.extended(
            onPressed: controller.navigateToCreateReminder,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Reminder'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ✅ Fixed: Added BuildContext parameter
  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Loading medicine reminders...',
            style: AppTheme.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Fixed: Already has BuildContext parameter
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
              controller.errorMessage.value,
              style: AppTheme.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () => controller.refreshData(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Fixed: Added BuildContext parameter and used it instead of Get.context!
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(context: context), // ✅ Fixed
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medicine Reminders',
                      style: AppTheme.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Manage your patient\'s medication schedule',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                count: controller.totalReminders,
                label: 'Total',
                color: AppColors.primary,
              ),
              _buildStatItem(
                count: controller.activeReminders,
                label: 'Active',
                color: Colors.green,
              ),
              _buildStatItem(
                count: controller.dueTodayCount,
                label: 'Due Today',
                color: Colors.blue,
              ),
              _buildStatItem(
                count: controller.inactiveReminders,
                label: 'Inactive',
                color: AppColors.onSurfaceVariant,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required int count,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: AppColors.surfaceContainerLow, width: 1),
          ),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: AppTheme.labelMedium.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Row(
      children: [
        Expanded(
          child: Text(
            controller.showActiveOnly.value
                ? 'Showing active reminders'
                : 'Showing all reminders',
            style: AppTheme.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        Obx(
          () => Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFilterChip(
                  label: 'All',
                  isSelected: !controller.showActiveOnly.value,
                  onTap: () => controller.showActiveOnly.value = false,
                ),
                _buildFilterChip(
                  label: 'Active',
                  isSelected: controller.showActiveOnly.value,
                  onTap: () => controller.showActiveOnly.value = true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTheme.labelMedium.copyWith(
            color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ✅ Fixed: Added BuildContext parameter and used it instead of Get.context!
  Widget _buildRemindersList(BuildContext context) {
    final filtered = controller.filteredReminders;

    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: AppTheme.cardDecoration(context: context), // ✅ Fixed
        child: Column(
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 56,
              color: AppColors.onSurfaceVariant.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No medicine reminders found',
              style: AppTheme.bodyLarge.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.showActiveOnly.value
                  ? 'No active reminders. Tap "Add Reminder" to create one.'
                  : 'Tap "Add Reminder" to create your first medicine reminder.',
              style: AppTheme.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length + (controller.hasMoreData.value ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == filtered.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        }

        final reminder = filtered[index];
        return MedicineReminderCard(
          reminder: reminder,
          onTap: () => controller.navigateToEditReminder(reminder),
          onEdit: () => controller.navigateToEditReminder(reminder),
          onDelete: () => controller.deleteReminder(reminder),
          onToggle: () => controller.toggleReminderStatus(reminder),
        );
      },
    );
  }
}
