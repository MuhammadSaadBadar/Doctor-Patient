// lib/patient/features/diet_plan/screens/diet_plan_detail_screen.dart

import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/patient/features/dashboard/models/diet_plan_summary.dart';
import 'package:doctor/patient/features/diet_plan/controllers/diet_plan_detail_controller.dart';
import 'package:doctor/patient/features/dashboard/models/diet_meal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DietPlanDetailScreen extends GetView<DietPlanDetailController> {
  const DietPlanDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Diet Plan',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final p = controller.plan.value;
        if (p == null) {
          return _buildLoadingState(context);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(p, colorScheme),
              const SizedBox(height: 24),
              _buildHydrationCard(p, colorScheme),
              const SizedBox(height: 24),
              _buildMealsSection(p, colorScheme),
              if (p.notes != null && p.notes!.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildNotesCard(p, colorScheme),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeaderCard(DietPlanSummary plan, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.withOpacity(0.12),
            Colors.orange.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_menu_rounded,
              size: 28,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Diet Plan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                // Text('Prescribed by $doctorName', style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHydrationCard(DietPlanSummary plan, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop_rounded, size: 22, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Hydration Goal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${plan.hydrationGlasses} glasses',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${plan.hydrationMl} ml daily',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.water_drop_rounded,
                  size: 40,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealsSection(DietPlanSummary plan, ColorScheme colorScheme) {
    final meals = plan.meals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meals',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        if (meals.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.3),
              ),
            ),
            child: Center(
              child: Text(
                'No meals specified in this plan',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
          )
        else
          Column(
            children: meals
                .map((meal) => _buildMealCard(meal, colorScheme))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildMealCard(DietMeal meal, ColorScheme colorScheme) {
    Color mealColor;
    IconData mealIcon;
    switch (meal.mealType) {
      case 'breakfast':
        mealColor = Colors.amber;
        mealIcon = Icons.wb_sunny_rounded;
        break;
      case 'lunch':
        mealColor = Colors.orange;
        mealIcon = Icons.wb_sunny_outlined;
        break;
      case 'dinner':
        mealColor = Colors.deepOrange;
        mealIcon = Icons.nightlight_round;
        break;
      case 'snack':
        mealColor = Colors.green;
        mealIcon = Icons.cookie_rounded;
        break;
      default:
        mealColor = colorScheme.primary;
        mealIcon = Icons.restaurant_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: mealColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(mealIcon, size: 24, color: mealColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.mealTypeLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meal.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(DietPlanSummary plan, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes_rounded, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Doctor\'s Notes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            plan.notes!,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface,
              height: 1.5,
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
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Loading...',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
