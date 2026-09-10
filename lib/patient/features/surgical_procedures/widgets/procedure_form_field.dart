// lib/patient/features/surgical_procedures/widgets/procedure_form_field.dart

import 'package:flutter/material.dart';

class ProcedureFormField extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData icon;
  final TextEditingController controller;
  final bool required;
  final TextInputType keyboardType;
  final VoidCallback? onTap;
  final bool readOnly;
  final String? errorText;
  final Widget? suffix;

  const ProcedureFormField({
    super.key,
    required this.label,
    this.hint,
    required this.icon,
    required this.controller,
    this.required = false,
    this.keyboardType = TextInputType.text,
    this.onTap,
    this.readOnly = false,
    this.errorText,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: textScale.scale(12).clamp(10.0, 16.0),
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 2),
              Text(
                '*',
                style: TextStyle(
                  fontSize: textScale.scale(12).clamp(10.0, 16.0),
                  fontWeight: FontWeight.w500,
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
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: errorText != null && errorText!.isNotEmpty
                    ? colorScheme.error
                    : colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: errorText != null && errorText!.isNotEmpty ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 14),
                  child: Icon(icon, size: 20, color: colorScheme.primary),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    readOnly: readOnly,
                    keyboardType: keyboardType,
                    maxLines: readOnly ? 1 : null,
                    minLines: readOnly ? 1 : 1,
                    maxLength: readOnly ? null : 500,
                    onChanged: (_) {},
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(
                        color: colorScheme.outline,
                        fontSize: textScale.scale(12).clamp(10.0, 16.0),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      counterText: '',
                    ),
                    style: TextStyle(
                      fontSize: textScale.scale(12).clamp(10.0, 16.0),
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
            style: TextStyle(
              fontSize: textScale.scale(10).clamp(8.0, 14.0),
              color: colorScheme.error
            ),
          ),
        ],
      ],
    );
  }
}
