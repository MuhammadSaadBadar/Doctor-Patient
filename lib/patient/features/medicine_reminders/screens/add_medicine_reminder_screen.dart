// lib/patient/features/medicine_reminders/screens/add_medicine_reminder_screen.dart

import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:doctor/patient/features/medicine_reminders/controllers/add_medicine_reminder_controller.dart';
import 'package:doctor/patient/features/medicine_reminders/widgets/reminder_form_field.dart';
import 'package:doctor/patient/features/medicine_reminders/widgets/reminder_stepper.dart';
import 'package:doctor/patient/features/medicine_reminders/widgets/reminder_time_chip.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddMedicineReminderScreen extends GetView<AddMedicineReminderController> {
  const AddMedicineReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: PatientTopAppBar(
        title: 'Medicine Reminder',
        titleBuilder: (_) => Obx(
          () => Text(
            controller.getTitle(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              fontFamily: 'PlayfairDisplay',
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState(context);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          child: Column(
            children: [
              // Hero Section
              _buildHeroSection(context),
              const SizedBox(height: 16),

              // Medicine Name
              Obx(
                () => ReminderFormField(
                  label: 'Medicine Name',
                  hint: 'e.g., Folic Acid, Iron',
                  icon: Icons.medication_rounded,
                  controller: controller.medicineNameController,
                  required: true,
                  errorText: controller.medicineNameError.value,
                  onTap: null,
                ),
              ),
              const SizedBox(height: 16),

              // Dosage
              ReminderFormField(
                label: 'Dosage',
                hint: 'e.g., 5mg, 25mg, 1000mg',
                icon: Icons.medication_rounded,
                controller: controller.dosageController,
                required: false,
              ),
              const SizedBox(height: 16),

              // Times per day
              _buildTimesPerDaySection(context),
              const SizedBox(height: 16),

              // Reminder Times
              _buildReminderTimesSection(context),
              const SizedBox(height: 16),

              // Dates
              _buildDatesSection(context),
              const SizedBox(height: 16),

              // Active Toggle
              _buildActiveToggle(context),
              const SizedBox(height: 24),

              // Action Buttons
              _buildActionButtons(context),
              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.04),
            colorScheme.primary.withOpacity(0.01),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Nurturing Care',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Obx(
            () => Text(
              controller.isEditing.value
                  ? 'Update Your Medicine Reminder'
                  : 'Daily Supplement & Medicine',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                fontFamily: 'PlayfairDisplay',
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Set up gentle reminders to keep you and your little one healthy and strong.',
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildTimesPerDaySection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Times per day',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '*',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'How many times daily?',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Obx(
            () => ReminderStepper(
              value: controller.timesPerDay.value,
              onIncrement: controller.incrementTimesPerDay,
              onDecrement: controller.decrementTimesPerDay,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderTimesSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.alarm_rounded,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Reminder Times',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '*',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: controller.addReminderTime,
                child: Row(
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Add Time',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            if (controller.reminderTimes.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No reminder times added yet',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.reminderTimes.asMap().entries.map((entry) {
                final index = entry.key;
                final time = entry.value;
                return ReminderTimeChip(
                  time: controller.getDisplayTime(time),
                  onRemove: () => controller.removeReminderTime(index),
                );
              }).toList(),
            );
          }),
          if (controller.reminderTimesError.value.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              controller.reminderTimesError.value,
              style: TextStyle(fontSize: 12, color: colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }

Widget _buildDatesSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Start Date',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '*',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Obx(
                  () => GestureDetector(
                    onTap: () => controller.pickStartDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: controller.startDateError.value.isNotEmpty
                              ? colorScheme.error
                              : colorScheme.outlineVariant.withOpacity(0.3),
                          width: controller.startDateError.value.isNotEmpty
                              ? 2
                              : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              controller.startDate.value != null
                                  ? _formatDate(controller.startDate.value!)
                                  : 'Select start date',
                              style: TextStyle(
                                fontSize: 14,
                                color: controller.startDate.value != null
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down_rounded,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (controller.startDateError.value.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    controller.startDateError.value,
                    style: TextStyle(fontSize: 12, color: colorScheme.error),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.event_busy_rounded,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'End Date',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(Optional)',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Obx(
                  () => GestureDetector(
                    onTap: () => controller.pickEndDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              controller.endDate.value != null
                                  ? _formatDate(controller.endDate.value!)
                                  : 'Select end date',
                              style: TextStyle(
                                fontSize: 14,
                                color: controller.endDate.value != null
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down_rounded,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Leave empty for ongoing reminders',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveToggle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active Reminder',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                'Reminders will be sent when active',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Obx(
            () => Transform.scale(
              scale: 0.8,
              child: Switch(
                value: controller.isActive.value,
                onChanged: (value) => controller.isActive.value = value,
                activeColor: colorScheme.primary,
                inactiveThumbColor: colorScheme.onSurfaceVariant,
                inactiveTrackColor: colorScheme.surfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(
      () => Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: controller.isSubmitting.value
                  ? null
                  : controller.cancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
                side: BorderSide(color: colorScheme.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: controller.isSubmitting.value
                  ? null
                  : controller.submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
                disabledBackgroundColor: colorScheme.onSurface.withOpacity(
                  0.12,
                ),
              ),
              child: controller.isSubmitting.value
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: colorScheme.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(controller.getSubmitLabel()),
                      ],
                    ),
            ),
          ),
        ],
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
            'Loading...',
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

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
