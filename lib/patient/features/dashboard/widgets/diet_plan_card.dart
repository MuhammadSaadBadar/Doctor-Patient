// lib/patient/features/dashboard/widgets/diet_plan_card.dart

import 'package:flutter/material.dart';

class DietPlanCard extends StatelessWidget {
  final dynamic plan;
  final VoidCallback onTap;

  const DietPlanCard({super.key, required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
              color: cs.shadow.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.restaurant_menu_rounded,
                    size: 18,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Diet Plan",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (plan.name != null)
                        Text(
                          plan.name,
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Macros Row
            LayoutBuilder(
              builder: (context, constraints) {
                final macros = [
                  _macroTile(
                    cs,
                    label: 'Calories',
                    value: '${plan.totalCalories ?? 0}',
                    unit: 'kcal',
                    color: Colors.orange,
                  ),
                  _macroTile(
                    cs,
                    label: 'Protein',
                    value: '${plan.proteinGrams ?? 0}',
                    unit: 'g',
                    color: Colors.pink,
                  ),
                  _macroTile(
                    cs,
                    label: 'Carbs',
                    value: '${plan.carbsGrams ?? 0}',
                    unit: 'g',
                    color: Colors.amber,
                  ),
                  _macroTile(
                    cs,
                    label: 'Fat',
                    value: '${plan.fatGrams ?? 0}',
                    unit: 'g',
                    color: Colors.teal,
                  ),
                ];

                // Use Wrap on narrow screens (< 360dp), Row on wider
                if (constraints.maxWidth < 360) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: macros,
                  );
                }

                return Row(
                  children: macros
                      .expand((tile) => [tile, const SizedBox(width: 8)])
                      .take(7) // 4 tiles + 3 spacers
                      .toList(),
                );
              },
            ),

            // Water Intake
            if (plan.waterGoalLiters != null) ...[
              const SizedBox(height: 14),
              Divider(color: cs.outlineVariant, height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.water_drop_rounded,
                      size: 14,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Water Intake',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${plan.waterConsumedLiters ?? 0}L / ${plan.waterGoalLiters}L',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value:
                      ((plan.waterConsumedLiters ?? 0) /
                              (plan.waterGoalLiters ?? 1))
                          .clamp(0.0, 1.0),
                  backgroundColor: cs.primary.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                  minHeight: 5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _macroTile(
    ColorScheme cs, {
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            Text(
              unit,
              style: TextStyle(fontSize: 9, color: color.withOpacity(0.8)),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}