// lib/patient/features/water_intake/widgets/hydration_tip_card.dart

import 'package:flutter/material.dart';

class HydrationTipCard extends StatelessWidget {
  final String tip;

  const HydrationTipCard({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryFixed.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.tertiaryFixed.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.tertiaryFixed,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.tips_and_updates_rounded,
              size: 22,
              color: colorScheme.tertiary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hydration Tip',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.tertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tip,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
