// lib/patient/features/surgical_procedures/widgets/procedure_notes_field.dart

import 'package:flutter/material.dart';

class ProcedureNotesField extends StatelessWidget {
  final TextEditingController controller;
  final int maxLength;

  const ProcedureNotesField({
    super.key,
    required this.controller,
    this.maxLength = 500,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textScale = MediaQuery.textScalerOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Notes',
              style: TextStyle(
                fontSize: textScale.scale(12).clamp(10.0, 16.0),
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              'Optional',
              style: TextStyle(
                fontSize: textScale.scale(10).clamp(8.0, 14.0),
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            // ✅ Dark: lifted inner field; Light: solid surface
            color: isDark
                ? colorScheme.surfaceContainerHigh
                : colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? colorScheme.primary.withValues(alpha: 0.20)
                  : colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 14, top: 14),
                child: Icon(
                  Icons.edit_note_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: 4,
                  minLines: 4,
                  maxLength: maxLength,
                  decoration: InputDecoration(
                    hintText: 'Add any notes about the procedure...',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                      fontSize: textScale.scale(12).clamp(10.0, 16.0),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    counterText: '${controller.text.length}/$maxLength',
                    counterStyle: TextStyle(
                      fontSize: textScale.scale(10).clamp(8.0, 14.0),
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: textScale.scale(12).clamp(10.0, 16.0),
                    color: colorScheme.onSurface,
                  ),
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
