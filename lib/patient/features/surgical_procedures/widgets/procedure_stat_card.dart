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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ✅ Prevents unbounded height issues
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color:
                    backgroundColor ??
                    colorScheme.primary.withValues(alpha: 0.1),
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
            // ✅ Removed Flexible wrapper
            value,
            style: TextStyle(
              fontSize: textScale.scale(18).clamp(14.0, 24.0),
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            // ✅ Removed Flexible wrapper
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
