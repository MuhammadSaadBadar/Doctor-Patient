// lib/patient/features/surgical_procedures/widgets/procedure_card.dart

import 'package:doctor/patient/features/surgical_procedures/models/surgical_procedure.dart';
import 'package:flutter/material.dart';

class ProcedureCard extends StatelessWidget {
  final SurgicalProcedure procedure;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProcedureCard({
    super.key,
    required this.procedure,
    required this.onEdit,
    required this.onDelete,
  });

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = _isDark(context);
    final textScale = MediaQuery.textScalerOf(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // ✅ Gradient-in-dark, solid-in-light
        gradient: isDark
            ? LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [
                  colorScheme.primary.withValues(alpha: 0.10),
                  colorScheme.primaryContainer.withValues(alpha: 0.06),
                ],
              )
            : null,
        color: !isDark ? colorScheme.surfaceContainerLowest : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? colorScheme.primary.withValues(alpha: 0.12)
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  // ✅ Category tint bumped in dark
                  color: procedure.categoryColor.withValues(
                    alpha: isDark ? 0.22 : 0.15,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  procedure.categoryIcon,
                  size: 22,
                  color: procedure.categoryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      procedure.procedureName,
                      style: TextStyle(
                        fontSize: textScale.scale(14).clamp(12.0, 18.0),
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          procedure.formattedDate,
                          style: TextStyle(
                            fontSize: textScale.scale(11).clamp(9.0, 15.0),
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colorScheme.outlineVariant,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            procedure.hospitalName ?? 'Unknown facility',
                            style: TextStyle(
                              fontSize: textScale.scale(11).clamp(9.0, 15.0),
                              fontWeight: FontWeight.w500,
                              color: colorScheme.secondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              // ✅ Category chip tint bumped in dark
              color: procedure.categoryColor.withValues(
                alpha: isDark ? 0.20 : 0.1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              procedure.category,
              style: TextStyle(
                fontSize: textScale.scale(9).clamp(7.0, 12.0),
                fontWeight: FontWeight.w600,
                color: procedure.categoryColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (procedure.notes != null && procedure.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // ✅ Notes box — dark uses stronger primary tint
                color: isDark
                    ? colorScheme.primary.withValues(alpha: 0.08)
                    : colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: isDark
                    ? Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.10),
                        width: 1,
                      )
                    : null,
              ),
              child: Text(
                procedure.notes!,
                style: TextStyle(
                  fontSize: textScale.scale(11).clamp(9.0, 15.0),
                  fontStyle: FontStyle.italic,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (procedure.notes != null && procedure.notes!.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      Icons.edit_note_rounded,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Clinical notes',
                      style: TextStyle(
                        fontSize: textScale.scale(10).clamp(8.0, 14.0),
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              Row(
                children: [
                  _buildActionButton(
                    context,
                    icon: Icons.edit_rounded,
                    onTap: onEdit,
                  ),
                  const SizedBox(width: 4),
                  _buildActionButton(
                    context,
                    icon: Icons.delete_rounded,
                    onTap: onDelete,
                    isDelete: true,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    bool isDelete = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    // ✅ Delete button — stronger contrast pair in dark
    final deleteBg = isDark
        ? colorScheme.error.withValues(alpha: 0.20)
        : colorScheme.errorContainer.withValues(alpha: 0.4);

    // ✅ Edit button — dark uses primary tint, light uses surfaceContainer
    final editBg = isDark
        ? colorScheme.primary.withValues(alpha: 0.14)
        : colorScheme.surfaceContainer;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isDelete ? deleteBg : editBg,
        shape: BoxShape.circle,
        border: isDark
            ? Border.all(
                color: isDelete
                    ? colorScheme.error.withValues(alpha: 0.35)
                    : colorScheme.primary.withValues(alpha: 0.20),
                width: 1,
              )
            : null,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 18,
          color: isDelete ? colorScheme.error : colorScheme.onSurfaceVariant,
        ),
        onPressed: onTap,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
