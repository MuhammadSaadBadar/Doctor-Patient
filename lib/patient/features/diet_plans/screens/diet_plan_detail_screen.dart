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
                // Plan Header
                DietPlanHeader(plan: plan),
                const SizedBox(height: 16),

                // Hydration Card
                if (plan.hasHydration)
                  HydrationCard(glasses: plan.hydrationRecommendationGlasses!),
                if (plan.hasHydration) const SizedBox(height: 16),

                // Meals Section
                _buildMealsSection(context, plan),
                const SizedBox(height: 16),

                // Foods to Avoid Section
                _buildFoodsToAvoidSection(context, plan),
                const SizedBox(height: 16),

                // Doctor Notes
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
    final colorScheme = Theme.of(context).colorScheme;

    if (!plan.hasMeals) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            TranslationKeys.dietNoMeals.tr,
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
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
                color: colorScheme.onSurface,
                fontFamily: 'PlayfairDisplay',
              ),
            ),
            Text(
              '${TranslationKeys.dietMealsSnacks.tr.replaceAll('@count', plan.mealCount.toString())}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colorScheme.primary,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TranslationKeys.dietFoodsToAvoid.tr,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            fontFamily: 'PlayfairDisplay',
          ),
        ),
        const SizedBox(height: 12),
        if (!plan.hasFoodsToAvoid)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, size: 20, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  TranslationKeys.dietNoFoodsToAvoid.tr,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
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
            TranslationKeys.dietLoadingPlan.tr,
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

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
                color: colorScheme.primaryContainer.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu_rounded,
                size: 40,
                color: colorScheme.primary.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              TranslationKeys.dietPlanNotFound.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                fontFamily: 'PlayfairDisplay',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              TranslationKeys.dietPlanNotFoundDesc.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.navigateBack,
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
              child: Text(TranslationKeys.commonBack.tr),
            ),
          ],
        ),
      ),
    );
  }
}
