// lib/patient/features/diet_plans/widgets/diet_plan_header.dart

import 'package:doctor/patient/features/diet_plans/models/diet_plan.dart';
import 'package:flutter/material.dart';

class DietPlanHeader extends StatelessWidget {
  final DietPlan plan;

  const DietPlanHeader({super.key, required this.plan});

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    // ✅ Semantic green that flips with brightness
    final activeFg = isDark ? Colors.green.shade300 : Colors.green.shade800;
    final inactiveFg = cs.onSurfaceVariant;

    return Column(
      children: [
        // Plan Number and Date
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    // ✅ Slightly stronger in dark
                    color: cs.primary.withOpacity(isDark ? 0.20 : 0.10),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'Plan ${plan.planNumber}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  plan.formattedCreatedAt,
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                // ✅ Semantic tint that flips with brightness
                color: plan.isActive
                    ? (isDark
                          ? Colors.green.withOpacity(0.20)
                          : Colors.green.withOpacity(0.12))
                    : (isDark
                          ? cs.onSurfaceVariant.withOpacity(0.15)
                          : Colors.grey.withOpacity(0.12)),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    plan.isActive
                        ? Icons.check_circle_rounded
                        : Icons.lock_clock_rounded,
                    size: 14,
                    color: plan.isActive ? activeFg : inactiveFg,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    plan.isActive ? 'Active Plan' : 'Inactive',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: plan.isActive ? activeFg : inactiveFg,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Doctor Info
        Container(
          padding: const EdgeInsets.all(12),
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
                      blurRadius: 16,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Doctor Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    colors: [cs.primary, cs.primary.withOpacity(0.7)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    plan.createdBy.firstName.isNotEmpty
                        ? plan.createdBy.firstName[0].toUpperCase()
                        : 'D',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: cs.onPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.doctorFullName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Diet plan provider',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.verified_rounded, size: 20, color: cs.primary),
            ],
          ),
        ),
      ],
    );
  }
}
