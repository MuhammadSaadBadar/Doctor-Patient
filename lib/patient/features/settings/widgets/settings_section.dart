import 'package:flutter/material.dart';
import 'package:doctor/core/constants/color_constants.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: AppTheme.labelMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}