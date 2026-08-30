// lib/features/patient/screens/create_edit_medicine_reminder_screen.dart

import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/top_app_bar.dart';
import 'package:doctor/doctor/features/patient/controllers/doc_create_edit_medicine_reminder_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorCreateEditMedicineReminderScreen
    extends GetView<DoctorCreateEditMedicineReminderController> {
  final bool isEditing;

  const DoctorCreateEditMedicineReminderScreen({
    super.key,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Column(
        children: [
          TopAppNavBar.gradient(
            title: isEditing
                ? 'Edit Medicine Reminder'
                : 'New Medicine Reminder',
            height: 64,
            showBackButton: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientInfo(context),
                  const SizedBox(height: 20),
                  _buildFormCard(context),
                  const SizedBox(height: 24),
                  _buildSubmitButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfo(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(context: context), // ✅ Fixed
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_rounded,
              color: colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient',
                  style: AppTheme.labelMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  controller.patientName.isNotEmpty
                      ? controller.patientName
                      : 'Unknown Patient',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              isEditing ? 'Editing' : 'New',
              style: AppTheme.labelMedium.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration(context: context), // ✅ Fixed
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medicine Name
            Text(
              'Medicine Name *',
              style: AppTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: controller.medicineNameController,
              decoration: InputDecoration(
                hintText: 'e.g. Folic Acid',
                hintStyle: TextStyle(
                  color: AppColors.onSurfaceVariant.withOpacity(0.5),
                ),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                errorText: controller.medicineNameError.value.isNotEmpty
                    ? controller.medicineNameError.value
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Dosage
            Text(
              'Dosage',
              style: AppTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: controller.dosageController,
              decoration: InputDecoration(
                hintText: 'e.g. 5mg',
                hintStyle: TextStyle(
                  color: AppColors.onSurfaceVariant.withOpacity(0.5),
                ),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Times Per Day
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Times Per Day *',
                        style: AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<int>(
                        value: controller.timesPerDay.value,
                        items: List.generate(6, (i) => i + 1).map((value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.timesPerDay.value = value;
                            controller.updateReminderTimes();
                          }
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          errorText:
                              controller.timesPerDayError.value.isNotEmpty
                              ? controller.timesPerDayError.value
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<bool>(
                            value: controller.isActive.value,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                value: true,
                                child: Text('Active'),
                              ),
                              DropdownMenuItem(
                                value: false,
                                child: Text('Inactive'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                controller.isActive.value = value;
                              }
                            },
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppColors.onSurface,
                            ),
                            icon: Icon(
                              Icons.arrow_drop_down_rounded,
                              color: AppColors.onSurfaceVariant,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Reminder Times
            Text(
              'Reminder Times *',
              style: AppTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ...controller.reminderTimes.map((time) {
              final index = controller.reminderTimes.indexOf(time);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.surfaceVariant,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _formatTimeForDisplay(time),
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _showTimePicker(context, index),
                      icon: const Icon(
                        Icons.access_time_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    if (controller.reminderTimes.length > 1)
                      IconButton(
                        onPressed: () => controller.removeReminderTime(index),
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Colors.red,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              );
            }),
            if (controller.reminderTimesError.value.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                controller.reminderTimesError.value,
                style: AppTheme.bodySmall.copyWith(
                  color: AppColors.error,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: controller.addReminderTime,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Time'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
            const SizedBox(height: 16),

            // Dates
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Date *',
                        style: AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () => _selectDate(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.surfaceVariant,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  controller.startDate.value
                                      .toIso8601String()
                                      .split('T')[0],
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down_rounded,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'End Date (Optional)',
                        style: AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () => _selectDate(context, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.surfaceVariant,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  controller.endDate.value != null
                                      ? controller.endDate.value!
                                            .toIso8601String()
                                            .split('T')[0]
                                      : 'No end date',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: controller.endDate.value != null
                                        ? AppColors.onSurface
                                        : AppColors.onSurfaceVariant
                                              .withOpacity(0.5),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: controller.clearEndDate,
                                icon: const Icon(Icons.close_rounded, size: 16),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                color: AppColors.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: controller.isSubmitting.value ? null : controller.submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
          ),
          child: controller.isSubmitting.value
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.onPrimary,
                  ),
                )
              : Text(
                  isEditing ? 'Update Reminder' : 'Create Reminder',
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimary,
                  ),
                ),
        ),
      ),
    );
  }

  String _formatTimeForDisplay(String time) {
    try {
      final parts = time.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
      }
      return time;
    } catch (_) {
      return time;
    }
  }

  void _showTimePicker(BuildContext context, int index) async {
    final currentTime = controller.reminderTimes[index];
    final parts = currentTime.split(':');
    final initialHour = int.tryParse(parts[0]) ?? 8;
    final initialMinute = int.tryParse(parts[1]) ?? 0;

    final time = await showTimePicker(
      context: context, // ✅ Fixed
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).colorScheme.surface,
              hourMinuteTextColor: Theme.of(context).colorScheme.onSurface,
              dayPeriodTextColor: Theme.of(context).colorScheme.onSurface,
              dialHandColor: Theme.of(context).colorScheme.primary,
              dialBackgroundColor: Theme.of(
                context,
              ).colorScheme.primaryContainer,
              entryModeIconColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      final formatted =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      controller.updateReminderTime(index, formatted);
    }
  }

  void _selectDate(BuildContext context, bool isStartDate) async {
    final currentDate = isStartDate
        ? controller.startDate.value
        : (controller.endDate.value ?? DateTime.now());

    final date = await showDatePicker(
      context: context, // ✅ Fixed
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Theme.of(context).colorScheme.surface,
              headerBackgroundColor: Theme.of(
                context,
              ).colorScheme.primaryContainer,
              headerForegroundColor: Theme.of(
                context,
              ).colorScheme.onPrimaryContainer,
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Theme.of(context).colorScheme.onPrimary;
                }
                return Theme.of(context).colorScheme.onSurface;
              }),
              todayForegroundColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.primary,
              ),
              yearForegroundColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      if (isStartDate) {
        controller.startDate.value = date;
      } else {
        controller.endDate.value = date;
      }
    }
  }
}
