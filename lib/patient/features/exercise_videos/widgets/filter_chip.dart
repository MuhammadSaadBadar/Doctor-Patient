// lib/patient/features/exercise_videos/widgets/filter_chip.dart

import 'package:flutter/material.dart';

class ExerciseFilterChip extends StatelessWidget {
  final String id;
  final String label;
  final IconData icon;
  final bool isSelected;
  final int count;
  final VoidCallback onTap;
  final Color color;

  const ExerciseFilterChip({
    super.key,
    required this.id,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.count,
    required this.onTap,
    required this.color,
  });

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);
    final textScale = MediaQuery.textScalerOf(context);

    // ✅ Unselected chip — gradient-in-dark / surface-in-light
    final unselectedDecoration = BoxDecoration(
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
      color: !isDark ? cs.surfaceContainerHighest : null,
      borderRadius: BorderRadius.circular(30),
      border: isDark
          ? Border.all(color: cs.primary.withOpacity(0.18), width: 1)
          : null,
    );

    // ✅ Selected chip — solid `color` (caller passes a theme-aware hue)
    final selectedDecoration = BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(isDark ? 0.35 : 0.20),
          blurRadius: isDark ? 10 : 8,
          offset: const Offset(0, 2),
        ),
      ],
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: textScale.scale(10).clamp(8.0, 16.0),
          vertical: textScale.scale(6).clamp(4.0, 12.0),
        ),
        decoration: isSelected ? selectedDecoration : unselectedDecoration,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: textScale.scale(11).clamp(9.0, 14.0),
                fontWeight: FontWeight.w600,
                color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  // ✅ Selected count badge: strong onPrimary tint
                  // ✅ Unselected count badge: stronger in dark
                  color: isSelected
                      ? cs.onPrimary.withOpacity(0.22)
                      : (isDark
                            ? cs.primary.withOpacity(0.18)
                            : cs.surfaceContainerHighest),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: textScale.scale(9).clamp(7.0, 12.0),
                    fontWeight: FontWeight.w700,
                    color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
