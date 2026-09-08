// lib/patient/features/ai_assistant/widgets/typing_indicator.dart

import 'package:flutter/material.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(colorScheme, delay: 0),
                const SizedBox(width: 4),
                _buildDot(colorScheme, delay: 0.2),
                const SizedBox(width: 4),
                _buildDot(colorScheme, delay: 0.4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(ColorScheme colorScheme, {required double delay}) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: colorScheme.outlineVariant,
        shape: BoxShape.circle,
      ),
    );
  }
}
