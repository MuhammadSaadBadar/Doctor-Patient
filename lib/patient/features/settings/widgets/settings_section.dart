// lib/patient/features/settings/widgets/settings_section.dart

import 'package:flutter/material.dart';
import 'package:doctor/core/themes/app_theme.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: AppTheme.labelMedium.copyWith(
              // ✅ Section title: pink accent in dark mode for visual hierarchy
              color: isDark
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            // ✅ Dark mode: gradient (matches QuickActionGrid & other widgets)
            // ✅ Light mode: white surface (unchanged)
            gradient: isDark
                ? LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    colors: [
                      colorScheme.primary.withOpacity(0.10),
                      colorScheme.primaryContainer.withOpacity(0.06),
                    ],
                  )
                : null,
            color: !isDark ? colorScheme.surfaceContainerLowest : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? colorScheme.primary.withOpacity(0.12)
                  : colorScheme.outlineVariant.withOpacity(0.5),
              width: 1,
            ),
            // ✅ Subtle shadow in dark mode for depth
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}
