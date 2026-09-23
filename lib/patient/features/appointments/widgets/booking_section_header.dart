// lib/patient/features/appointments/widgets/booking_section_header.dart

import 'package:flutter/material.dart';

class BookingSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;

  const BookingSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon!,
                size: 20,
                // ✅ Dark: bright pink; Light: primary (unchanged)
                color: isDark
                    ? colorScheme.primaryFixed
                    : colorScheme.primary,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 13,
              // ✅ Dark: slightly muted; Light: onSurfaceVariant (unchanged)
              color: isDark
                  ? colorScheme.onSurfaceVariant.withOpacity(0.8)
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}