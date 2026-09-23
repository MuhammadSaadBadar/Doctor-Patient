// lib/patient/features/settings/widgets/settings_tile.dart

import 'package:flutter/material.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';

class SettingsTile extends StatelessWidget {
  final String icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? textColor;
  final Color? iconColor;
  final bool isFirst;
  final bool isLast;
  final bool isOnly;
  final Widget? trailing;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.textColor,
    this.iconColor,
    this.isFirst = false,
    this.isLast = false,
    this.isOnly = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderRadius = BorderRadius.only(
      topLeft: isFirst || isOnly ? const Radius.circular(12) : Radius.zero,
      topRight: isFirst || isOnly ? const Radius.circular(12) : Radius.zero,
      bottomLeft: isLast || isOnly ? const Radius.circular(12) : Radius.zero,
      bottomRight: isLast || isOnly ? const Radius.circular(12) : Radius.zero,
    );

    // ✅ Dark mode: use primary-tinted hover/highlight for theme consistency
    // ✅ Light mode: use surfaceContainerLow as before
    final hoverColor = isDark
        ? colorScheme.primary.withOpacity(0.10)
        : colorScheme.surfaceContainerLow.withOpacity(0.5);

    final highlightColor = isDark
        ? colorScheme.primary.withOpacity(0.06)
        : colorScheme.surfaceContainerLow.withOpacity(0.3);

    // ✅ Resolve text colors (dark mode uses brighter onSurface)
    final resolvedTextColor = textColor ?? colorScheme.onSurface;
    final resolvedIconColor =
        iconColor ??
        (isDark ? colorScheme.primary : colorScheme.onSurfaceVariant);
    final resolvedChevronColor = isDark
        ? colorScheme.primary.withOpacity(0.6)
        : colorScheme.outline;
    final resolvedSubtitleColor = isDark
        ? colorScheme.onSurfaceVariant.withOpacity(0.75)
        : colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        hoverColor: hoverColor,
        highlightColor: highlightColor,
        splashColor: isDark
            ? colorScheme.primary.withOpacity(0.08)
            : colorScheme.primary.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              MaterialSymbolIcon(icon, size: 24, color: resolvedIconColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodyMedium.copyWith(
                        color: resolvedTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTheme.bodySmall.copyWith(
                          color: resolvedSubtitleColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
              if (onTap != null && trailing == null)
                MaterialSymbolIcon(
                  'chevron_right',
                  size: 24,
                  color: resolvedChevronColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
