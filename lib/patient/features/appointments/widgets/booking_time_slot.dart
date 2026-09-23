// lib/patient/features/appointments/widgets/booking_time_slot.dart

import 'package:flutter/material.dart';

class BookingTimeSlot extends StatelessWidget {
  final TimeOfDay time;
  final bool isSelected;
  final VoidCallback onTap;

  const BookingTimeSlot({
    super.key,
    required this.time,
    required this.isSelected,
    required this.onTap,
  });

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    // Selected: solid primary (bright and unmissable)
    final selectedDecoration = BoxDecoration(
      color: cs.primary,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: cs.primary, width: 2),
      boxShadow: [
        BoxShadow(
          color: cs.primary.withValues(alpha: isDark ? 0.40 : 0.25),
          blurRadius: isDark ? 12 : 10,
          offset: const Offset(0, 4),
        ),
      ],
    );

    // Unselected: gradient-in-dark / solid-in-light
    // (matches every other card in the app)
    final unselectedDecoration = BoxDecoration(
      gradient: isDark
          ? LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [
                cs.primary.withValues(alpha: 0.10),
                cs.primaryContainer.withValues(alpha: 0.06),
              ],
            )
          : null,
      color: !isDark ? cs.surfaceContainerLowest : null,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: isDark
            ? cs.primary.withValues(alpha: 0.18)
            : cs.outlineVariant.withValues(alpha: 0.4),
        width: 1,
      ),
      boxShadow: isDark
          ? [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ]
          : null,
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: isSelected ? selectedDecoration : unselectedDecoration,
        child: Center(
          child: Text(
            _formatTimeOfDay(time),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              // ✅ Selected: onPrimary (pairs with solid primary bg)
              // ✅ Unselected: onSurface on both themes
              color: isSelected ? cs.onPrimary : cs.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
