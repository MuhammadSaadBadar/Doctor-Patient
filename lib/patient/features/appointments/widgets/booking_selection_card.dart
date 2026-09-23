// lib/patient/features/appointments/widgets/booking_selection_card.dart

import 'package:flutter/material.dart';

class BookingSelectionCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const BookingSelectionCard({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // ✅ Dark: gradient surface; Light: solid surfaceContainerLowest (unchanged)
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
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? colorScheme.primary.withOpacity(0.15)
                : colorScheme.outline.withOpacity(0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? colorScheme.shadow.withOpacity(0.05)
                  : colorScheme.shadow.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}