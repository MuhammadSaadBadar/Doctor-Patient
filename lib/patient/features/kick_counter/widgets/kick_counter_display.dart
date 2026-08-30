// lib/patient/features/kick_counter/widgets/kick_counter_display.dart

import 'package:flutter/material.dart';

class KickCounterDisplay extends StatelessWidget {
  final int kickCount;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final bool isActive;

  const KickCounterDisplay({
    super.key,
    required this.kickCount,
    required this.onAdd,
    required this.onRemove,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
              color: isActive
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withOpacity(0.3),
              width: isActive ? 4 : 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  'Current Kicks',
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
                        value: isActive ? 0.3 : 1.0, // Visual indicator only
                        strokeWidth: 5,
                        backgroundColor: colorScheme.primary.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      '$kickCount',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
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
                      enabled: isActive && kickCount > 0,
                    ),
                    const SizedBox(width: 8),
                    _buildCounterButton(
                      icon: Icons.add_rounded,
                      onTap: onAdd,
                      colorScheme: colorScheme,
                      isAdd: true,
                      size: buttonSize,
                      enabled: isActive,
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
              ? (enabled ? colorScheme.primary : colorScheme.primary.withOpacity(0.3))
              : colorScheme.surfaceContainer,
          boxShadow: isAdd && enabled
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isAdd
              ? (enabled ? colorScheme.onPrimary : colorScheme.onPrimary.withOpacity(0.4))
              : (enabled ? colorScheme.primary : colorScheme.primary.withOpacity(0.4)),
          size: size * 0.5,
        ),
      ),
    );
  }
}