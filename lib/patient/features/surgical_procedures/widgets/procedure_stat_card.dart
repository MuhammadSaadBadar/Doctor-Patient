// lib/patient/features/surgical_procedures/widgets/procedure_stat_card.dart

import 'package:flutter/material.dart';

class ProcedureStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;

  const ProcedureStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
  });

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = _isDark(context);
    final textScale = MediaQuery.textScalerOf(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // ✅ Gradient-in-dark, solid-in-light
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
        color: !isDark ? colorScheme.surfaceContainerLowest : null,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? colorScheme.primary.withValues(alpha: 0.12)
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                // ✅ Caller already provides a brightened tint in dark
                color:
                    backgroundColor ??
                    colorScheme.primary.withValues(alpha: isDark ? 0.22 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 16,
                color: iconColor ?? colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: textScale.scale(18).clamp(14.0, 24.0),
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: textScale.scale(10).clamp(8.0, 13.0),
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
