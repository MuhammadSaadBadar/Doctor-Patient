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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 2),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
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
              color: colorScheme.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: errorText != null && errorText!.isNotEmpty
                    ? colorScheme.error
                    : colorScheme.outlineVariant.withOpacity(0.3),
                width: errorText != null && errorText!.isNotEmpty ? 2 : 1,
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
                        color: colorScheme.outlineVariant,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                if (suffix != null) suffix!,
              ],
            ),
          ),
        ),
        if (errorText != null && errorText!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: TextStyle(fontSize: 12, color: colorScheme.error),
          ),
        ],
      ],
    );
  }
}
