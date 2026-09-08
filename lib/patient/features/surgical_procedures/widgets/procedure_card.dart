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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ✅ Prevents unbounded height issues
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: procedure.categoryColor.withValues(alpha: 0.15),
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
                  mainAxisSize: MainAxisSize.min, // ✅ Added
                  children: [
                    Text(
                      // ✅ Removed Flexible wrapper
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
                          // ✅ Removed Flexible wrapper
                          procedure.formattedDate,
                          style: TextStyle(
                            fontSize: textScale.scale(11).clamp(9.0, 15.0),
                            color: colorScheme.outline,
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
              color: procedure.categoryColor.withValues(alpha: 0.1),
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
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                // ✅ Removed Flexible wrapper
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

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isDelete
            ? colorScheme.errorContainer.withValues(alpha: 0.4)
            : colorScheme.surfaceContainer,
        shape: BoxShape.circle,
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
