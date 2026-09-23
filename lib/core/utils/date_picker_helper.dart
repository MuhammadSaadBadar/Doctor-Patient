// lib/core/utils/date_picker_helper.dart

import 'package:flutter/material.dart';
import 'package:doctor/core/constants/color_constants.dart';

/// A centralized helper for showing a themed DatePicker that works
/// correctly in both light and dark mode.
///
/// Fixes the default Material DatePicker issue where non-selected dates
/// become invisible in dark mode (dark text on dark background).
class AppDatePicker {
  AppDatePicker._();

  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    String? helpText,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: helpText,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              // ── Background ────────────────────────────────────────
              backgroundColor: isDark
                  ? AppColors.primaryDark // Fix: surfaceContainerLow renders white in this app
                  : AppColors.surfaceContainerLowest,

              // ── Header ────────────────────────────────────────────
              headerBackgroundColor: isDark ? AppColors.primaryDark : colorScheme.primary,
              headerForegroundColor: colorScheme.onPrimary,

              // ── Day text (MAIN FIX) ───────────────────────────────
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return colorScheme.onPrimary;
                }
                if (states.contains(WidgetState.disabled)) {
                  return isDark 
                      ? AppColors.onPrimary.withOpacity(0.3)
                      : colorScheme.onSurface.withOpacity(0.3);
                }
                // Fix: Non-selected dates should be white in dark mode against the dark background
                return isDark ? AppColors.onPrimary : colorScheme.onSurface;
              }),

              // ── Selected day background ───────────────────────────
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return isDark ? AppColors.primary : colorScheme.primary;
                }
                return null;
              }),

              // ── Day shape (selected = filled circle) ──────────────
              dayShape: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const CircleBorder();
                }
                return null;
              }),

              // ── Year / month labels ───────────────────────────────
              yearForegroundColor: WidgetStatePropertyAll(
                isDark ? AppColors.onPrimary : colorScheme.onSurface,
              ),
              yearBackgroundColor: WidgetStatePropertyAll(
                isDark ? AppColors.primaryDark : colorScheme.surfaceContainerLowest,
              ),

              // ── Input field (year picker) ─────────────────────────
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: isDark ? AppColors.primary : colorScheme.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? AppColors.outline : colorScheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? AppColors.outline : colorScheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? AppColors.onPrimary : colorScheme.primary, width: 2),
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
