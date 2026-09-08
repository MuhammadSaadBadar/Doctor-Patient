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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.outline.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.03),
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
