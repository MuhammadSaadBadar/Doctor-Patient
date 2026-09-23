// lib/patient/features/medicine_reminders/widgets/reminder_form_field.dart

import 'package:flutter/material.dart';

class ReminderFormField extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData icon;
  final TextEditingController controller;
  final bool required;
  final TextInputType keyboardType;
  final String? errorText;
  final Widget? suffix;
  final bool readOnly;
  final VoidCallback? onTap;

  const ReminderFormField({
    super.key,
    required this.label,
    this.hint,
    required this.icon,
    required this.controller,
    this.required = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.suffix,
    this.readOnly = false,
    this.onTap,
  });

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: cs.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 2),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              // ✅ Dark: primary gradient over the scaffold — same pattern
              //    as every other card in the app. NEVER `surfaceContainerHigh`
              //    because that token renders white in this app's dark scheme.
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
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError
                    ? cs.error
                    : (isDark
                          ? cs.primary.withValues(alpha: 0.20)
                          : cs.outlineVariant.withValues(alpha: 0.3)),
                width: hasError ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    readOnly: readOnly,
                    keyboardType: keyboardType,
                    onChanged: (_) {},
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: TextStyle(fontSize: 14, color: cs.onSurface),
                  ),
                ),
                if (suffix != null) suffix!,
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(errorText!, style: TextStyle(fontSize: 12, color: cs.error)),
        ],
      ],
    );
  }
}
