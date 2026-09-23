// lib/patient/features/diet_plans/screens/diet_plan_detail_screen.dart

import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:doctor/patient/features/diet_plans/controllers/diet_plan_controller.dart'
    show DietPlanController;
import 'package:doctor/patient/features/diet_plans/models/diet_plan.dart';
import 'package:doctor/patient/features/diet_plans/widgets/diet_plan_header.dart';
import 'package:doctor/patient/features/diet_plans/widgets/doctor_note_card.dart';
import 'package:doctor/patient/features/diet_plans/widgets/food_avoidance_item.dart';
import 'package:doctor/patient/features/diet_plans/widgets/hydration_card.dart';
import 'package:doctor/patient/features/diet_plans/widgets/meal_card.dart';
import 'package:doctor/core/localization/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DietPlanDetailScreen extends GetView<DietPlanController> {
  const DietPlanDetailScreen({super.key});

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Semantic hue helper (matches other refactored screens).
  Color _semanticFg(BuildContext context, Color base) {
    final isDark = _isDark(context);
    if (base == Colors.green)
      return isDark ? Colors.green.shade300 : Colors.green.shade800;
    if (base == Colors.red)
      return isDark ? Colors.red.shade300 : Colors.red.shade800;
    return base;
  }

  Color _semanticBg(BuildContext context, Color base) {
    final isDark = _isDark(context);
    return base.withOpacity(isDark ? 0.16 : 0.08);
  }

  Color _semanticBorder(BuildContext context, Color base) {
    final isDark = _isDark(context);
    return base.withOpacity(isDark ? 0.45 : 0.30);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: PatientTopAppBar(title: TranslationKeys.dietPlanTitle.tr),
      body: Obx(() {
        if (controller.isLoading.value && controller.dietPlan.value == null) {
          return _buildLoadingState(context);
        }

        if (controller.hasError.value && controller.dietPlan.value == null) {
          return _buildErrorState(context);
        }

        final plan = controller.dietPlan.value;
        if (plan == null) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            child: Column(
              children: [
                DietPlanHeader(plan: plan),
                const SizedBox(height: 16),
                if (plan.hasHydration)
                  HydrationCard(glasses: plan.hydrationRecommendationGlasses!),
                if (plan.hasHydration) const SizedBox(height: 16),
                _buildMealsSection(context, plan),
                const SizedBox(height: 16),
                _buildFoodsToAvoidSection(context, plan),
                const SizedBox(height: 16),
                if (plan.hasNotes) DoctorNoteCard(notes: plan.notes!),
                if (plan.hasNotes) const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMealsSection(BuildContext context, DietPlan plan) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    if (!plan.hasMeals) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? cs.primary.withOpacity(0.12)
                : cs.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            TranslationKeys.dietNoMeals.tr,
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              TranslationKeys.dietDailyMealPlan.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
                fontFamily: 'PlayfairDisplay',
              ),
            ),
            Text(
              '${TranslationKeys.dietMealsSnacks.tr.replaceAll('@count', plan.mealCount.toString())}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: cs.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: plan.meals.map((meal) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: MealCard(meal: meal),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFoodsToAvoidSection(BuildContext context, DietPlan plan) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TranslationKeys.dietFoodsToAvoid.tr,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
            fontFamily: 'PlayfairDisplay',
          ),
        ),
        const SizedBox(height: 12),
        if (!plan.hasFoodsToAvoid)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
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
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? cs.primary.withOpacity(0.12)
                    : cs.outlineVariant.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  // ✅ Semantic green that flips with brightness
                  color: _semanticFg(context, Colors.green),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    TranslationKeys.dietNoFoodsToAvoid.tr,
                    style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              // ✅ Semantic red panel that flips with brightness
              color: _semanticBg(context, Colors.red),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _semanticBorder(context, Colors.red),
                width: 1,
              ),
            ),
            child: Column(
              children: plan.foodsToAvoid.map((item) {
                return FoodAvoidanceItem(item: item);
              }).toList(),
            ),
          ),
      ],
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
            TranslationKeys.dietLoadingPlan.tr,
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
                // ✅ Correct contrast pair
                color: cs.onErrorContainer,
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
              ),
              child: Text(TranslationKeys.commonTryAgain.tr),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

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
                // ✅ Slightly stronger in dark
                color: isDark
                    ? cs.primary.withOpacity(0.18)
                    : cs.primaryContainer.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu_rounded,
                size: 40,
                color: cs.primary.withOpacity(isDark ? 0.7 : 0.4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              TranslationKeys.dietPlanNotFound.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
                fontFamily: 'PlayfairDisplay',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              TranslationKeys.dietPlanNotFoundDesc.tr,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.navigateBack,
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
              child: Text(TranslationKeys.commonBack.tr),
            ),
          ],
        ),
      ),
    );
  }
}
