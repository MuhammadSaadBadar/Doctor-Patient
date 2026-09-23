// lib/patient/features/diet_plans/widgets/hydration_card.dart

import 'package:flutter/material.dart';

class HydrationCard extends StatelessWidget {
  final int glasses;

  const HydrationCard({super.key, required this.glasses});

  // ✅ Constant blue accent for water — same hue in both themes
  static const Color _waterBlue = Color(0xFF8BA7E8);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ Blue reads better in dark when lightened
    final waterColor = isDark ? const Color(0xFFA8BEF0) : _waterBlue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ✅ In dark: gradient tint over scaffold with water-blue accent
        // ✅ In light: original blue-tinted gradient
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: isDark
              ? [
                  waterColor.withOpacity(0.14),
                  cs.primaryContainer.withOpacity(0.06),
                  waterColor.withOpacity(0.08),
                ]
              : [
                  _waterBlue.withOpacity(0.15),
                  cs.surfaceContainerLowest,
                  _waterBlue.withOpacity(0.08),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? waterColor.withOpacity(0.28) : Colors.transparent,
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: waterColor.withOpacity(isDark ? 0.22 : 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.water_drop_rounded,
                  size: 32,
                  color: waterColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$glasses glasses',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      'Daily Hydration Goal',
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
