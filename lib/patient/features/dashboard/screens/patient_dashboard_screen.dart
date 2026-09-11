// lib/patient/features/dashboard/screens/dashboard_screen.dart

import 'package:doctor/core/localization/translation_keys.dart';
import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:doctor/patient/features/dashboard/controllers/patient_dashboard_controller.dart';
import 'package:doctor/patient/features/dashboard/widgets/appointment_card.dart';
import 'package:doctor/patient/features/dashboard/widgets/diet_plan_card.dart';
import 'package:doctor/patient/features/dashboard/widgets/medicine_adherence_card.dart';
import 'package:doctor/patient/features/dashboard/widgets/pregnancy_progress_card.dart';
import 'package:doctor/patient/features/dashboard/widgets/quick_action_grid.dart';
import 'package:doctor/patient/features/dashboard/widgets/symptom_summary.dart';
import 'package:doctor/patient/features/dashboard/widgets/vital_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PatientDashboardScreen extends GetView<PatientDashboardController> {
  const PatientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: PatientTopAppBar(
        title: TranslationKeys.appTitle.tr,
        showBackButton: false,
        onNotificationTap: () => Get.toNamed('/notifications'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) return _buildLoadingState(context);
        if (controller.hasError.value) return _buildErrorState(context);

        final summary = controller.summary.value;
        if (summary == null) return _buildEmptyState(context);

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: cs.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pregnancy Progress
                if (summary.hasPregnancyData) ...[
                  PregnancyProgressCard(
                    progress: summary.pregnancyProgress!,
                    babySize: controller.babySize.value,
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  _buildLmpInstructionCard(context),
                  const SizedBox(height: 16),
                ],

                // Vitals Summary
                if (summary.latestBloodPressure != null ||
                    summary.latestBloodSugar != null) ...[
                  _sectionHeader(context, TranslationKeys.dashboardVitals.tr),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (summary.latestBloodPressure != null)
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              minWidth: 140,
                              maxWidth: 180,
                            ),
                            child: VitalCard.bloodPressure(
                              reading: summary.latestBloodPressure!,
                            ),
                          ),
                        if (summary.latestBloodSugar != null) ...[
                          const SizedBox(width: 12),
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              minWidth: 140,
                              maxWidth: 180,
                            ),
                            child: VitalCard.bloodSugar(
                              reading: summary.latestBloodSugar!,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Quick Actions
                _sectionHeader(
                  context,
                  TranslationKeys.dashboardQuickActions.tr,
                ),
                const SizedBox(height: 10),

                QuickActionGrid(
                  actions: [
                    QuickAction(
                      label: TranslationKeys.dashboardLogSymptoms.tr,
                      icon: Icons.sick_rounded,
                      color: Colors.pink,
                      onTap: controller.navigateToSymptoms,
                    ),
                    QuickAction(
                      label: TranslationKeys.dashboardWaterIntake.tr,
                      icon: Icons.water_drop_rounded,
                      color: Colors.blue,
                      onTap: controller.navigateToWaterIntake,
                    ),
                    QuickAction(
                      label: TranslationKeys.dashboardKickCount.tr,
                      icon: Icons.child_care_rounded,
                      color: Colors.purple,
                      onTap: controller.navigateToKickCount,
                    ),
                    QuickAction(
                      label: TranslationKeys.dashboardLogVitals.tr,
                      icon: Icons.favorite_rounded,
                      color: Colors.red,
                      onTap: controller.navigateToVitals,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                QuickActionGrid(
                  actions: [
                    QuickAction(
                      label: TranslationKeys.dashboardMyAppointments.tr,
                      icon: Icons.calendar_month_rounded,
                      color: Colors.deepPurple,
                      onTap: controller.navigateToAppointments,
                    ),
                    QuickAction(
                      label: TranslationKeys.dashboardMedicineReminder.tr,
                      icon: Icons.medication_rounded,
                      color: Colors.teal,
                      onTap: controller.navigateToMedicineReminders,
                    ),
                    QuickAction(
                      label: TranslationKeys.dashboardSurgicalProcedures.tr,
                      icon: Icons.local_hospital_rounded,
                      color: Colors.cyan,
                      onTap: controller.navigateToSurgicalProcedures,
                    ),

                    QuickAction(
                      label: TranslationKeys.dashboardBookAppointment.tr,
                      icon: Icons.medical_services_rounded,
                      color: Colors.green,
                      onTap: controller.navigateToFindDoctors,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                QuickActionGrid(
                  actions: [
                    QuickAction(
                      label: TranslationKeys.dashboardDietPlan.tr,
                      icon: Icons.restaurant_menu_rounded,
                      color: Colors.orange,
                      onTap: controller.navigateToDietPlan,
                    ),
                    // QuickAction(
                    //   label: TranslationKeys.dashboardAiAssistant.tr,
                    //   icon: Icons.auto_awesome_rounded,
                    //   color: Colors.indigo,
                    //   onTap: controller.navigateToAIAssistant,
                    // ),
                    QuickAction(
                      label: TranslationKeys.dashboardExerciseVideos.tr,
                      icon: Icons.self_improvement_rounded,
                      color: const Color(0xFF8BA7E8),
                      onTap: controller.navigateToExerciseVideos,
                    ),
                    QuickAction(
                      label: TranslationKeys.dashboardEmergency.tr,
                      icon: Icons.emergency_rounded,
                      color: Colors.red,
                      onTap: controller.navigateToEmergency,
                    ),
                    QuickAction(
                      label: TranslationKeys.dashboardSettings.tr,
                      icon: Icons.settings_rounded,
                      color: Colors.teal,
                      onTap: controller.navigateToSettings,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Active Diet Plan
                if (summary.hasActiveDietPlan) ...[
                  DietPlanCard(
                    plan: summary.activeDietPlan!,
                    onTap: controller.navigateToDietPlan,
                  ),
                  const SizedBox(height: 20),
                ],

                // Upcoming Appointments
                if (summary.hasUpcomingAppointments) ...[
                  _sectionHeader(
                    context,
                    TranslationKeys.dashboardUpcomingAppointments.tr,
                    onViewAll: controller.navigateToAppointments,
                  ),
                  const SizedBox(height: 10),
                  ...summary.upcomingAppointments.take(2).map((appt) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppointmentCard(
                        appointment: appt,
                        onTap: () =>
                            controller.navigateToAppointmentDetail(appt.id),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ],

                // Recent Symptoms
                if (summary.hasRecentSymptoms) ...[
                  _sectionHeader(
                    context,
                    TranslationKeys.dashboardRecentSymptoms.tr,
                    onViewAll: controller.navigateToSymptoms,
                  ),
                  const SizedBox(height: 10),
                  ...summary.recentSymptoms.take(2).map((log) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SymptomSummary(
                        log: log,
                        onTap: controller.navigateToSymptoms,
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ],

                // Medicine Adherence
                MedicineAdherenceCard(
                  adherence: summary.medicineAdherence,
                  onTap: () => Get.toNamed(AppRoutes.medicineReminders),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _sectionHeader(
    BuildContext context,
    String title, {
    VoidCallback? onViewAll,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
            letterSpacing: -0.2,
          ),
        ),
        if (onViewAll != null)
          InkWell(
            onTap: onViewAll,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    TranslationKeys.dashboardViewAll.tr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: cs.primary,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(16),
            child: CircularProgressIndicator(
              color: cs.primary,
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            TranslationKeys.dashboardLoadingHealthData.tr,
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
                color: cs.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              TranslationKeys.commonSomethingWentWrong.tr,
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
                elevation: 0,
              ),
              child: Text(TranslationKeys.commonTryAgain.tr),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLmpInstructionCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            cs.primary.withOpacity(0.10),
            cs.primaryContainer.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(Icons.pregnant_woman, size: 16, color: cs.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pregnancy Progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              TranslationKeys.dashboardLmpInstruction.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
                color: cs.primaryContainer.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.health_and_safety_rounded,
                size: 40,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              TranslationKeys.dashboardWelcome.tr,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              TranslationKeys.dashboardCompleteProfileDesc.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.toNamed('/profile/edit'),
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
                elevation: 0,
              ),
              child: Text(TranslationKeys.dashboardCompleteProfileBtn.tr),
            ),
          ],
        ),
      ),
    );
  }
}
