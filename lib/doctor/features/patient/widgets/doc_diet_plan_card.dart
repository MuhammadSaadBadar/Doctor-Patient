import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';
import 'package:doctor/doctor/features/patient/models/doc_diet_plan.dart';
import 'package:flutter/material.dart';

class DietPlanCard extends StatelessWidget {
  final DietPlan plan;
  final VoidCallback onTap;
  final bool showDelete;
  final VoidCallback? onDelete;

  const DietPlanCard({
    super.key,
    required this.plan,
    required this.onTap,
    this.showDelete = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.primary, width: 1),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Opacity(
          opacity: plan.opacity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            plan.planNumber > 0
                                ? 'Plan ${plan.planNumber}'
                                : plan.title,
                            style: AppTheme.headlineSmall.copyWith(
                              color: colorScheme.onPrimaryContainer,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(context),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      plan.description,
                      style: AppTheme.bodyMedium.copyWith(
                        color: colorScheme.onPrimaryContainer.withValues(
                          alpha: 0.8,
                        ),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Delete button or Arrow icon
              if (showDelete && onDelete != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 8),
                  child: Material(
                    color: colorScheme.errorContainer,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: colorScheme.error,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: MaterialSymbolIcon(
                    'chevron_right',
                    size: 24,
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.4,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: plan.statusBgColor,
        borderRadius: BorderRadius.circular(9999),
        border: plan.hasBorder
            ? Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              )
            : null,
      ),
      child: Text(
        plan.statusDisplay,
        style: AppTheme.labelMedium.copyWith(
          color: plan.statusTextColor,
          fontSize: 10,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
