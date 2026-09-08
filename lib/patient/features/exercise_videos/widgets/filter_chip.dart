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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: textScale.scale(10).clamp(8.0, 16.0),
          vertical: textScale.scale(6).clamp(4.0, 12.0),
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
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
                  color: isSelected
                      ? cs.onPrimary.withValues(alpha: 0.2)
                      : cs.surfaceContainerHighest,
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
