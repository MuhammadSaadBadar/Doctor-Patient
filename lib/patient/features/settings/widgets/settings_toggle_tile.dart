// lib/patient/features/settings/widgets/settings_toggle_tile.dart

import 'package:flutter/material.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';

class SettingsToggleTile extends StatelessWidget {
  final String icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isFirst;
  final bool isLast;

  const SettingsToggleTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderRadius = BorderRadiusDirectional.only(
      topStart: isFirst ? const Radius.circular(12) : Radius.zero,
      topEnd: isFirst ? const Radius.circular(12) : Radius.zero,
      bottomStart: isLast ? const Radius.circular(12) : Radius.zero,
      bottomEnd: isLast ? const Radius.circular(12) : Radius.zero,
    );

    // ✅ Theme-aware colors
    final iconColor = isDark
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    final subtitleColor = isDark
        ? colorScheme.onSurfaceVariant.withOpacity(0.75)
        : colorScheme.onSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Colors.transparent,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            MaterialSymbolIcon(icon, size: 24, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyMedium.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTheme.bodySmall.copyWith(color: subtitleColor),
                    ),
                  ],
                ],
              ),
            ),
            // ✅ Theme-aware Switch (dark mode gets stronger contrast)
            Switch(
              value: value,
              onChanged: onChanged,
              // Light mode: pink thumb on pink track
              // Dark mode: bright pink thumb on darker pink track
              activeColor: isDark ? colorScheme.primary : colorScheme.onPrimary,
              activeTrackColor: isDark
                  ? colorScheme.primary.withOpacity(0.35)
                  : colorScheme.primary.withOpacity(0.12),
              inactiveTrackColor: isDark
                  ? colorScheme.surfaceContainerHigh
                  : colorScheme.surfaceVariant,
              inactiveThumbColor: isDark
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.surface,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}
