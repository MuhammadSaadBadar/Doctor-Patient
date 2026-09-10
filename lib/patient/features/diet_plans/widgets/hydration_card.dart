// lib/patient/features/diet_plans/widgets/hydration_card.dart

import 'package:flutter/material.dart';

class HydrationCard extends StatelessWidget {
  final int glasses;

  const HydrationCard({super.key, required this.glasses});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            const Color(0xFF8BA7E8).withOpacity(0.15),
            colorScheme.surfaceContainerLowest,
            const Color(0xFF8BA7E8).withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.04),
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
                  color: const Color(0xFF8BA7E8).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.water_drop_rounded,
                  size: 32,
                  color: const Color(0xFF8BA7E8),
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
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Daily Hydration Goal',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
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
