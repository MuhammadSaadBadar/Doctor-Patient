// lib/patient/features/surgical_procedures/widgets/procedure_empty_state.dart

import 'package:flutter/material.dart';

class ProcedureEmptyState extends StatelessWidget {
  final VoidCallback onAddTap;

  const ProcedureEmptyState({super.key, required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textScale = MediaQuery.textScalerOf(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                // ✅ Stronger tint in dark
                color: isDark
                    ? colorScheme.primary.withValues(alpha: 0.18)
                    : colorScheme.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medical_services_rounded,
                size: 40,
                color: colorScheme.primary.withValues(
                  alpha: isDark ? 0.7 : 0.4,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Surgical Records Yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: textScale.scale(16).clamp(14.0, 22.0),
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                fontFamily: 'PlayfairDisplay',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Keep your care team informed by logging any past surgeries or procedures.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: textScale.scale(12).clamp(10.0, 16.0),
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAddTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Add First Procedure',
                    style: TextStyle(
                      fontSize: textScale.scale(12).clamp(10.0, 16.0),
                    ),
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
