// lib/patient/features/kick_counter/widgets/kick_counter_display.dart

import 'package:doctor/core/localization/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth * 0.65;
        final clampedSize = size.clamp(150.0, 220.0);
        final fontSize = clampedSize * 0.28;
        final buttonSize = clampedSize * 0.22;

        return Container(
          width: clampedSize,
          height: clampedSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // ✅ Dark: gradient to lift circle; Light: solid surface
            gradient: isDark
                ? LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    colors: [
                      cs.primary.withOpacity(0.10),
                      cs.primaryContainer.withOpacity(0.06),
                    ],
                  )
                : null,
            color: !isDark ? cs.surfaceContainerLowest : null,
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: cs.shadow.withOpacity(0.06),
                      blurRadius: 16,
                    ),
                  ],
            border: Border.all(
              color: isActive
                  ? cs.primary
                  : (isDark
                        ? cs.primary.withOpacity(0.20)
                        : cs.outlineVariant.withOpacity(0.3)),
              width: isActive ? 4 : 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  TranslationKeys.kickCounterCurrent.tr,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    color: cs.onSurfaceVariant,
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
                        value: isActive ? 0.3 : 1.0,
                        strokeWidth: 5,
                        // ✅ Stronger tint in dark
                        backgroundColor: cs.primary.withOpacity(
                          isDark ? 0.18 : 0.1,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isActive ? cs.primary : cs.onSurfaceVariant,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      '$kickCount',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        color: isActive ? cs.primary : cs.onSurfaceVariant,
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
                      colorScheme: cs,
                      isAdd: false,
                      size: buttonSize,
                      enabled: isActive && kickCount > 0,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildCounterButton(
                      icon: Icons.add_rounded,
                      onTap: onAdd,
                      colorScheme: cs,
                      isAdd: true,
                      size: buttonSize,
                      enabled: isActive,
                      isDark: isDark,
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
    required bool isDark,
  }) {
    // ✅ Minus button background — lifted surface in dark
    final minusBg = isDark
        ? colorScheme.primaryContainer.withOpacity(0.20)
        : colorScheme.surfaceContainer;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isAdd
              ? (enabled
                    ? colorScheme.primary
                    : colorScheme.primary.withOpacity(0.3))
              : minusBg,
          boxShadow: isAdd && enabled
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(isDark ? 0.45 : 0.3),
                    blurRadius: isDark ? 10 : 8,
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
                    ? colorScheme.primary
                    : colorScheme.primary.withOpacity(0.4)),
          size: size * 0.5,
        ),
      ),
    );
  }
}
