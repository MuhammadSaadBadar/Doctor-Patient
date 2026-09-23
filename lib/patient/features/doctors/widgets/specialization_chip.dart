// lib/patient/features/doctors/widgets/specialization_chip.dart

import 'package:flutter/material.dart';

class SpecializationChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SpecializationChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = _isDark(context);
    final textScale = MediaQuery.textScalerOf(context);

    // ✅ Unselected chip — gradient in dark, solid in light
    final unselectedDecoration = BoxDecoration(
      gradient: isDark
          ? LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [
                colorScheme.primary.withValues(alpha: 0.10),
                colorScheme.primaryContainer.withValues(alpha: 0.06),
              ],
            )
          : null,
      color: !isDark ? colorScheme.surfaceContainerHigh : null,
      borderRadius: BorderRadius.circular(30),
      border: isDark
          ? Border.all(
              color: colorScheme.primary.withValues(alpha: 0.18),
              width: 1,
            )
          : null,
    );

    // ✅ Selected chip — solid primary + soft shadow
    final selectedDecoration = BoxDecoration(
      color: colorScheme.primary,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: colorScheme.primary.withValues(alpha: isDark ? 0.35 : 0.3),
          blurRadius: isDark ? 10 : 8,
          offset: const Offset(0, 2),
        ),
      ],
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: textScale.scale(14).clamp(10.0, 20.0),
          vertical: textScale.scale(6).clamp(4.0, 12.0),
        ),
        decoration: isSelected ? selectedDecoration : unselectedDecoration,
        child: Text(
          label,
          style: TextStyle(
            fontSize: textScale.scale(11).clamp(9.0, 14.0),
            fontWeight: FontWeight.w500,
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
