import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/bottom_nav_bar.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';
import 'package:doctor/core/widgets/top_app_bar.dart';
import 'package:doctor/features/patient/controllers/patient_detail_controller.dart';
import 'package:doctor/features/patient/models/patient.dart';
import 'package:doctor/features/patient/models/symptom.dart';
import 'package:doctor/features/patient/models/water_intake.dart';
import 'package:doctor/features/patient/widgets/diet_plan_card.dart';
import 'package:doctor/features/patient/widgets/patient_header.dart';
import 'package:doctor/features/patient/widgets/symptom_list.dart';
import 'package:doctor/features/patient/widgets/pregnancy_progress_card.dart';
import 'package:doctor/features/patient/widgets/upcoming_appointment_card.dart';
import 'package:doctor/features/patient/widgets/blood_pressure_chart.dart';
import 'package:doctor/features/patient/widgets/blood_sugar_chart.dart';
import 'package:doctor/features/patient/widgets/vital_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PatientDetailScreen extends GetView<PatientDetailController> {
  const PatientDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Column(
        children: [
          // Top App Bar with Gradient
          TopAppNavBar.gradient(
            title: 'Patient Details',
            height: 64,
            showBackButton: true,
          ),

          // Main Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.patient.value == null) {
                return _buildLoadingState(context);
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return _buildErrorState(context);
              }

              final patient = controller.patient.value;

              if (patient == null) {
                return _buildEmptyPatientState(context);
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
                        // Patient Header
                        PatientHeader(patient: patient),
                        const SizedBox(height: 24),

                        // Navigation Buttons
                        _buildNavigationButtons(patient, isDesktop),
                        const SizedBox(height: 24),

                        // Navigation Tabs
                        _buildNavigationTabs(),
                        const SizedBox(height: 24),

                        // Tab Content
                        _buildTabContent(patient),
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
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Loading patient details...',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w400,
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

  Widget _buildEmptyPatientState(BuildContext context) {
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
                Icons.person_off_outlined,
                size: 36,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Patient data not available',
              style: AppTheme.titleMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to load patient information. Please try again.',
              style: AppTheme.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
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

  Widget _buildNavigationButtons(Patient patient, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0.0 : 0.0),
      child: Column(
        children: [
          // Manage Diet Plan Button
          _buildManageDietPlanButton(patient),
          const SizedBox(height: 12),
          // Manage Medicine Reminder Button
          _buildManageMedicineReminderButton(patient),
          const SizedBox(height: 12),
          // Message Patient Button
          _buildMessagePatientButton(patient),
        ],
      ),
    );
  }

  Widget _buildManageDietPlanButton(Patient patient) {
    final patientId = Get.arguments is Map
        ? Get.arguments['patientId'] as int?
        : null;
    final colorScheme = Theme.of(Get.context!).colorScheme;
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;

    final buttonBgColor = isDark ? colorScheme.secondary : colorScheme.primary;
    final buttonTextColor = isDark
        ? colorScheme.onSecondary
        : colorScheme.onPrimary;
    final disabledBgColor = isDark
        ? colorScheme.secondary.withOpacity(0.4)
        : colorScheme.primary.withOpacity(0.4);
    final disabledTextColor = isDark
        ? colorScheme.onSecondary.withOpacity(0.6)
        : colorScheme.onPrimary.withOpacity(0.6);

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: patientId == null
            ? null
            : () {
                Get.toNamed(
                  AppRoutes.dietPlans,
                  arguments: {'patientId': patientId},
                );
              },
        icon: Icon(
          Icons.restaurant_menu_rounded,
          size: 20,
          color: buttonTextColor,
        ),
        label: Text(
          'Manage Diet Plan',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: buttonTextColor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBgColor,
          foregroundColor: buttonTextColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          disabledBackgroundColor: disabledBgColor,
          disabledForegroundColor: disabledTextColor,
        ),
      ),
    );
  }

  Widget _buildManageMedicineReminderButton(Patient patient) {
    final patientId = Get.arguments is Map
        ? Get.arguments['patientId'] as int?
        : null;
    final patientName = patient.name;
    final colorScheme = Theme.of(Get.context!).colorScheme;
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;

    final buttonBgColor = isDark ? colorScheme.secondary : colorScheme.primary;
    final buttonTextColor = isDark
        ? colorScheme.onSecondary
        : colorScheme.onPrimary;
    final disabledBgColor = isDark
        ? colorScheme.secondary.withOpacity(0.4)
        : colorScheme.primary.withOpacity(0.4);
    final disabledTextColor = isDark
        ? colorScheme.onSecondary.withOpacity(0.6)
        : colorScheme.onPrimary.withOpacity(0.6);

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: patientId == null
            ? null
            : () {
                Get.toNamed(
                  AppRoutes.medicineReminders,
                  arguments: {
                    'patientId': patientId,
                    'patientName': patientName,
                  },
                );
              },
        icon: Icon(
          Icons.medical_services_rounded,
          size: 20,
          color: buttonTextColor,
        ),
        label: Text(
          'Manage Medicine Reminder',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: buttonTextColor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBgColor,
          foregroundColor: buttonTextColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          disabledBackgroundColor: disabledBgColor,
          disabledForegroundColor: disabledTextColor,
        ),
      ),
    );
  }

  Widget _buildMessagePatientButton(Patient patient) {
    final patientId = Get.arguments is Map
        ? Get.arguments['patientId'] as int?
        : null;
    final patientName = patient.name;
    final colorScheme = Theme.of(Get.context!).colorScheme;
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;

    final buttonBgColor = isDark ? colorScheme.secondary : colorScheme.primary;
    final buttonTextColor = isDark
        ? colorScheme.onSecondary
        : colorScheme.onPrimary;
    final disabledBgColor = isDark
        ? colorScheme.secondary.withOpacity(0.4)
        : colorScheme.primary.withOpacity(0.4);
    final disabledTextColor = isDark
        ? colorScheme.onSecondary.withOpacity(0.6)
        : colorScheme.onPrimary.withOpacity(0.6);

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: patientId == null
            ? null
            : () {
                Get.toNamed(
                  AppRoutes.sendMessage,
                  arguments: {
                    'patientId': patientId,
                    'patientName': patientName,
                  },
                );
              },
        icon: Icon(Icons.message_rounded, size: 20, color: buttonTextColor),
        label: Text(
          'Message Patient',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: buttonTextColor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBgColor,
          foregroundColor: buttonTextColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          disabledBackgroundColor: disabledBgColor,
          disabledForegroundColor: disabledTextColor,
        ),
      ),
    );
  }

  Widget _buildNavigationTabs() {
    const tabs = ['Overview', 'Vitals', 'Reports'];
    final colorScheme = Theme.of(Get.context!).colorScheme;
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceDim
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Obx(
        () => Row(
          children: List.generate(tabs.length, (index) {
            final isActive = index == controller.selectedTab.value;
            return Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => controller.selectTab(index),
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isActive
                          ? colorScheme.surface
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  isDark ? 0.2 : 0.06,
                                ),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      tabs[index],
                      textAlign: TextAlign.center,
                      style: AppTheme.bodyMedium.copyWith(
                        color: isActive
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTabContent(Patient patient) {
    return Obx(() {
      switch (controller.selectedTab.value) {
        case 0:
          return _buildOverviewTab(patient);
        case 1:
          return _buildVitalsTab(patient);
        case 2:
          return _buildReportsTab(patient);
        default:
          return _buildOverviewTab(patient);
      }
    });
  }

  Widget _buildOverviewTab(Patient patient) {
    final currentWeek =
        int.tryParse(patient.week.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PregnancyProgressCard.fromPatientSummary(
          lmpDate: patient.lmp,
          eddDate: patient.edd,
          currentWeek: currentWeek,
          currentDay: 0,
          percentComplete: (currentWeek / 40.0 * 100.0).clamp(0.0, 100.0),
          trimester: int.tryParse(
            patient.trimester?.replaceAll(RegExp(r'[^0-9]'), '') ?? '1',
          ),
          daysRemaining: null,
        ),
        const SizedBox(height: 16),
        Obx(
          () => UpcomingAppointmentCard(
            appointments: controller.upcomingAppointments.value,
            isLoading: controller.isLoadingAppointments.value,
          ),
        ),
      ],
    );
  }

  Widget _buildKickCountCard(Patient patient) {
    final colorScheme = Theme.of(Get.context!).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(context: Get.context!),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.child_care_rounded,
                    size: 17,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Kick Count',
                  style: AppTheme.headlineSmall.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(color: colorScheme.outlineVariant, height: 1),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withOpacity(0.75),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${controller.patient.value?.kickCount ?? 0}',
                      style: AppTheme.headlineMedium.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Kicks",
                        style: AppTheme.bodyMedium.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Active pattern noted',
                        style: AppTheme.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 12,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Normal',
                              style: AppTheme.labelMedium.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ],
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

  Widget _buildSymptomsSection(Patient patient) {
    final colorScheme = Theme.of(Get.context!).colorScheme;
    return SymptomList(
      symptoms: controller.symptoms.value,
      isLoading: controller.isLoadingSymptoms.value,
    );
  }

  Widget _buildWaterIntakeSection(Patient patient) {
    final colorScheme = Theme.of(Get.context!).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(context: Get.context!),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.water_drop_rounded,
                  size: 17,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Water Intake',
                style: AppTheme.headlineSmall.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => _buildWaterIntakeContent()),
        ],
      ),
    );
  }

  Widget _buildWaterIntakeContent() {
    final entries = controller.waterIntakeEntries;
    final todayTotal = controller.todayWaterIntake.value;
    final goal = 2500; // Default goal
    final percentage = (todayTotal / goal).clamp(0.0, 1.0);

    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.water_drop_outlined,
                  size: 28,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No water intake records yet',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final sortedEntries = List<WaterIntakeEntry>.from(entries)
      ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Bar
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Intake',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$todayTotal ml of ${goal}ml goal',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: AppTheme.headlineSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 10,
            backgroundColor: AppColors.surfaceContainerLow,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 16),
        // Recent Entries
        Text(
          'Recent Entries',
          style: AppTheme.bodyMedium.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        ...sortedEntries.take(5).map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.water_drop_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.amountMl} ml',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatDateTime(entry.loggedAt),
                        style: AppTheme.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dayStr;
    if (date == today) {
      dayStr = 'Today';
    } else if (date == yesterday) {
      dayStr = 'Yesterday';
    } else {
      dayStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$dayStr at $hour:$minute';
  }

  Widget _buildVitalsTab(Patient patient) {
    final colorScheme = Theme.of(Get.context!).colorScheme;
    final patientId = controller.patientId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => BloodPressureChart(
            patient: patient,
            history: controller.bloodPressureHistory.toList(),
            patientId: patientId,
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => BloodSugarChart(
            patient: patient,
            history: controller.bloodSugarHistory.toList(),
            patientId: patientId,
          ),
        ),
        const SizedBox(height: 16),
        _buildKickCountCard(patient),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildReportsTab(Patient patient) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWaterIntakeSection(patient),
        const SizedBox(height: 16),
        _buildSymptomsSection(patient),
      ],
    );
  }
}
