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

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Card decoration matching every other card in the app.
  /// Dark mode ALWAYS uses the primary gradient — never a `surfaceContainer*`
  /// token, because those render white in this app's dark scheme.
  BoxDecoration _cardDecoration(
    BuildContext context, {
    double radius = 12,
    Border? border,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    return BoxDecoration(
      gradient: isDark
          ? LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [
                cs.primary.withValues(alpha: 0.10),
                cs.primaryContainer.withValues(alpha: 0.06),
              ],
            )
          : null,
      color: !isDark ? cs.surfaceContainerLowest : null,
      borderRadius: BorderRadius.circular(radius),
      border:
          border ??
          Border.all(
            color: isDark
                ? cs.primary.withValues(alpha: 0.12)
                : cs.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
      boxShadow: isDark
          ? [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ]
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // ✅ surface, not deprecated background
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
              _buildHeroSection(context),
              const SizedBox(height: 16),
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
              ReminderFormField(
                label: 'Dosage',
                hint: 'e.g., 5mg, 25mg, 1000mg',
                icon: Icons.medication_rounded,
                controller: controller.dosageController,
                required: false,
              ),
              const SizedBox(height: 16),
              _buildTimesPerDaySection(context),
              const SizedBox(height: 16),
              _buildReminderTimesSection(context),
              const SizedBox(height: 16),
              _buildDatesSection(context),
              const SizedBox(height: 16),
              _buildActiveToggle(context),
              const SizedBox(height: 24),
              _buildActionButtons(context),
              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Hero uses a stronger gradient in dark for the "featured" feel
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            cs.primary.withValues(alpha: isDark ? 0.14 : 0.04),
            cs.primary.withValues(alpha: isDark ? 0.04 : 0.01),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? cs.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite_rounded, size: 20, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                'Nurturing Care',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: cs.primary,
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
                color: cs.onSurface,
                fontFamily: 'PlayfairDisplay',
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Set up gentle reminders to keep you and your little one healthy and strong.',
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildTimesPerDaySection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 20, color: cs.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Times per day',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '*',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'How many times daily?',
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
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
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.alarm_rounded, size: 20, color: cs.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Reminder Times',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '*',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: controller.addReminderTime,
                child: Row(
                  children: [
                    Icon(Icons.add_rounded, size: 16, color: cs.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Add Time',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cs.primary,
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
                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
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
              style: TextStyle(fontSize: 12, color: cs.error),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDatesSection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    return Row(
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 20,
                      color: cs.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Start Date',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '*',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
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
                        // ✅ Dark: primary-tinted inner field; Light: solid surface
                        gradient: isDark
                            ? LinearGradient(
                                begin: AlignmentDirectional.topStart,
                                end: AlignmentDirectional.bottomEnd,
                                colors: [
                                  cs.primary.withValues(alpha: 0.10),
                                  cs.primaryContainer.withValues(alpha: 0.06),
                                ],
                              )
                            : null,
                        color: !isDark ? cs.surfaceContainerLowest : null,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: controller.startDateError.value.isNotEmpty
                              ? cs.error
                              : (isDark
                                    ? cs.primary.withValues(alpha: 0.20)
                                    : cs.outlineVariant.withValues(alpha: 0.3)),
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
                                    ? cs.onSurface
                                    : cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down_rounded,
                            color: cs.onSurfaceVariant,
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
                    style: TextStyle(fontSize: 12, color: cs.error),
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
            decoration: _cardDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy_rounded, size: 20, color: cs.primary),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'End Date',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '(Optional)',
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
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
                        // ✅ Dark: primary-tinted inner field; Light: solid surface
                        gradient: isDark
                            ? LinearGradient(
                                begin: AlignmentDirectional.topStart,
                                end: AlignmentDirectional.bottomEnd,
                                colors: [
                                  cs.primary.withValues(alpha: 0.10),
                                  cs.primaryContainer.withValues(alpha: 0.06),
                                ],
                              )
                            : null,
                        color: !isDark ? cs.surfaceContainerLowest : null,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? cs.primary.withValues(alpha: 0.20)
                              : cs.outlineVariant.withValues(alpha: 0.3),
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
                                    ? cs.onSurface
                                    : cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down_rounded,
                            color: cs.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Leave empty for ongoing reminders',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveToggle(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context),
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
                  color: cs.onSurface,
                ),
              ),
              Text(
                'Reminders will be sent when active',
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
              ),
            ],
          ),
          Obx(
            () => Transform.scale(
              scale: 0.8,
              child: Switch(
                value: controller.isActive.value,
                onChanged: (value) => controller.isActive.value = value,
                // ✅ Theme-aware switch (matches SettingsToggleTile)
                activeColor: isDark ? cs.primary : cs.onPrimary,
                activeTrackColor: isDark
                    ? cs.primary.withValues(alpha: 0.35)
                    : cs.primary.withValues(alpha: 0.12),
                inactiveTrackColor: isDark
                    ? cs.primary.withValues(alpha: 0.18)
                    : cs.surfaceVariant,
                inactiveThumbColor: isDark ? cs.onSurfaceVariant : cs.surface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    return Obx(
      () => Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: controller.isSubmitting.value
                  ? null
                  : controller.cancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.primary,
                side: BorderSide(color: cs.primary),
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
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
                // ✅ Theme-aware disabled colors (dark: primary-tinted;
                //    light: neutral muted surface)
                disabledBackgroundColor: isDark
                    ? cs.primary.withValues(alpha: 0.18)
                    : cs.onSurface.withValues(alpha: 0.12),
                disabledForegroundColor: isDark
                    ? cs.onPrimary.withValues(alpha: 0.55)
                    : cs.onSurface.withValues(alpha: 0.38),
              ),
              child: controller.isSubmitting.value
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: cs.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_rounded, size: 18),
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
              color: cs.primaryContainer.withValues(
                alpha: isDark ? 0.35 : 0.15,
              ),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(color: cs.primary, strokeWidth: 3),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading...',
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
