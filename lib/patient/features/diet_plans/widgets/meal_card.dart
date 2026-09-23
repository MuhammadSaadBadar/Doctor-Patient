// lib/patient/features/diet_plans/widgets/meal_card.dart

import 'package:doctor/patient/features/diet_plans/models/diet_meal.dart';
import 'package:flutter/material.dart';

class MealCard extends StatelessWidget {
  final DietMeal meal;

  const MealCard({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        // ✅ Gradient in dark, solid in light
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
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: cs.shadow.withOpacity(0.04),
                  blurRadius: 12,
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
                  Text(meal.mealTypeIcon, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    meal.mealTypeLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            meal.description,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
