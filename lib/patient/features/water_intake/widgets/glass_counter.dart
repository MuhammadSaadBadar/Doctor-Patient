// lib/patient/features/water_intake/widgets/glass_counter.dart

import 'package:flutter/material.dart';

class GlassCounter extends StatelessWidget {
  final int glasses;
  final int targetGlasses;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const GlassCounter({
    super.key,
    required this.glasses,
    required this.targetGlasses,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = targetGlasses > 0
        ? (glasses / targetGlasses).clamp(0.0, 1.0)
        : 0.0;
    final isComplete = progress >= 1.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive sizing based on available width
        final size = constraints.maxWidth * 0.65;
        final clampedSize = size.clamp(150.0, 220.0);
        final fontSize = clampedSize * 0.28;
        final buttonSize = clampedSize * 0.22;

        return Container(
          width: clampedSize,
          height: clampedSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.surfaceContainerLowest,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.06),
                blurRadius: 16,
              ),
            ],
            border: Border.all(
              color: isComplete
                  ? colorScheme.tertiary
                  : colorScheme.tertiary.withOpacity(0.2),
              width: 4,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  'Current Glasses',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                flex: 3,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: clampedSize * 0.65,
                      height: clampedSize * 0.65,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 5,
                        backgroundColor: colorScheme.tertiary.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isComplete
                              ? colorScheme.tertiary
                              : colorScheme.primary,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      '$glasses',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.background,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCounterButton(
                      icon: Icons.remove_rounded,
                      onTap: onRemove,
                      colorScheme: colorScheme,
                      isAdd: false,
                      size: buttonSize,
                      enabled: glasses > 0,
                    ),
                    const SizedBox(width: 8),
                    _buildCounterButton(
                      icon: Icons.add_rounded,
                      onTap: onAdd,
                      colorScheme: colorScheme,
                      isAdd: true,
                      size: buttonSize,
                      enabled: glasses < targetGlasses,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required bool isAdd,
    required double size,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isAdd
              ? (enabled
                    ? colorScheme.tertiary
                    : colorScheme.tertiary.withOpacity(0.3))
              : colorScheme.surfaceContainer,
          boxShadow: isAdd && enabled
              ? [
                  BoxShadow(
                    color: colorScheme.tertiary.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isAdd
              ? (enabled
                    ? colorScheme.onPrimary
                    : colorScheme.onPrimary.withOpacity(0.4))
              : (enabled
                    ? colorScheme.tertiary
                    : colorScheme.tertiary.withOpacity(0.4)),
          size: size * 0.5,
        ),
      ),
    );
  }
}
