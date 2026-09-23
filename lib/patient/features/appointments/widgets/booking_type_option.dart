// lib/patient/features/appointments/widgets/booking_type_option.dart

import 'package:flutter/material.dart';

class BookingTypeOption extends StatelessWidget {
  final String type;
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const BookingTypeOption({
    super.key,
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    // ✅ The caller now passes a brightness-aware `color` (e.g. blue.shade300
    //    in dark, blue.shade600 in light), so we can use it directly.
    //    We still compute a couple of derived tones for tint/shadow.

    // Selected decoration — solid-ish accent tint + strong accent border
    final selectedDecoration = BoxDecoration(
      color: color.withValues(alpha: isDark ? 0.18 : 0.10),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: color.withValues(alpha: isDark ? 0.75 : 0.45),
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: isDark ? 0.30 : 0.15),
          blurRadius: isDark ? 14 : 12,
          offset: const Offset(0, 4),
        ),
      ],
    );

    // Unselected decoration — gradient-in-dark / solid-in-light
    // (matches SettingsSection, ProcedureCard, ReminderCard, etc.)
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
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: isDark
            ? cs.primary.withValues(alpha: 0.12)
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
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: isSelected ? selectedDecoration : unselectedDecoration,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // ✅ Selected: solid accent (bright in dark, saturated in light)
                //    Unselected: neutral tint that reads in both themes
                color: isSelected
                    ? color
                    : (isDark
                          ? cs.primary.withValues(alpha: 0.14)
                          : cs.surfaceContainerHighest),
                shape: BoxShape.circle,
                // ✅ Glow only on selected, only when we can afford it
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: isDark ? 0.45 : 0.30),
                          blurRadius: isDark ? 14 : 10,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                size: 22,
                // ✅ On a saturated accent button, use black/white depending
                //    on the accent's luminance. In dark mode the accent is
                //    already pastel (shade300), so use a dark foreground.
                color: isSelected
                    ? (isDark
                          ? Colors.black.withValues(alpha: 0.75)
                          : Colors.white)
                    : (isDark ? cs.primary : cs.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                // ✅ Selected text uses the accent (bright in dark / saturated
                //    in light); unselected uses onSurface / onSurfaceVariant
                color: isSelected
                    ? color
                    : (isDark ? cs.onSurface : cs.onSurfaceVariant),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
