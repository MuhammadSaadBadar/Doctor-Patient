// lib/patient/features/diet_plans/screens/diet_plans_screen.dart

import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:doctor/patient/features/diet_plans/controllers/diet_plan_list_controller.dart';
import 'package:doctor/patient/features/diet_plans/models/diet_plan.dart';
import 'package:doctor/core/localization/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DietPlansScreen extends GetView<DietPlanListController> {
  const DietPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: PatientTopAppBar(title: TranslationKeys.dietPlansTitle.tr),
      body: Obx(() {
        if (controller.isLoading.value && controller.plans.isEmpty) {
          return _LoadingState(colors: colors);
        }
        if (controller.hasError.value && controller.plans.isEmpty) {
          return _ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.refreshData,
          );
        }
        if (controller.plans.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.refreshData,
            color: colors.primary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [_EmptyState()],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: colors.primary,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            itemCount: controller.plans.length + 1,
            itemBuilder: (context, index) {
              if (index == controller.plans.length) {
                if (controller.hasMore.value) {
                  controller.loadMore();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(color: colors.primary),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }
              final plan = controller.plans[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DietPlanCard(
                  plan: plan,
                  onTap: () => controller.openPlan(plan),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

// ── Diet Plan Card ────────────────────────────────────────────────────────────

class _DietPlanCard extends StatelessWidget {
  final DietPlan plan;
  final VoidCallback onTap;

  const _DietPlanCard({required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isActive = plan.isActive;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? colors.tertiary.withOpacity(0.40)
                : colors.outlineVariant,
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Active accent bar
            if (isActive)
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: colors.tertiary,
                  borderRadius: const BorderRadiusDirectional.only(
                    topStart: Radius.circular(16),
                    topEnd: Radius.circular(16),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon container
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isActive
                          ? colors.tertiaryContainer
                          : colors.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.restaurant_menu_rounded,
                      color: isActive
                          ? colors.onTertiaryContainer
                          : colors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title + meta
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                TranslationKeys.dietPlanNumber.tr.replaceAll(
                                  '@number',
                                  plan.planNumber.toString(),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: colors.onSurface,
                                ),
                              ),
                            ),
                            if (isActive) ...[
                              const SizedBox(width: 8),
                              _ActiveBadge(colors: colors),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: _MetaChip(
                                icon: Icons.set_meal_rounded,
                                label: TranslationKeys.dietMeals.tr.replaceAll(
                                  '@count',
                                  plan.mealCount.toString(),
                                ),
                                colors: colors,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _MetaChip(
                                icon: Icons.calendar_today_rounded,
                                label: plan.formattedCreatedAt,
                                colors: colors,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Trailing chevron
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  final ColorScheme colors;
  const _ActiveBadge({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 11,
            color: colors.onTertiaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            TranslationKeys.dietActive.tr,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colors.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colors;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: colors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colors.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 80, 32, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant_menu_rounded,
              size: 32,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            TranslationKeys.dietNoPlans.tr,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            TranslationKeys.dietNoPlansDesc.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loading State ─────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  final ColorScheme colors;
  const _LoadingState({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator(color: colors.primary));
  }
}

// ── Error State ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.errorContainer.withOpacity(0.40),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                color: colors.error,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(TranslationKeys.commonRetry.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
