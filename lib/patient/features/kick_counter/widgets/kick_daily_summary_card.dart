// lib/patient/features/kick_counter/widgets/kick_daily_summary_card.dart

import 'package:doctor/core/localization/translation_keys.dart';
import 'package:doctor/patient/features/kick_counter/models/kick_daily_summary.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KickDailySummaryCard extends StatelessWidget {
  final KickDailySummary summary;
  final VoidCallback? onTap;

  const KickDailySummaryCard({super.key, required this.summary, this.onTap});

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _semanticFg(BuildContext context, Color base) {
    final isDark = _isDark(context);
    if (base == Colors.orange)
      return isDark ? Colors.orange.shade300 : Colors.orange.shade800;
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);
    final orangeFg = _semanticFg(context, Colors.orange);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // ✅ Gradient in dark, solid in light
          gradient: isDark
              ? LinearGradient(
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                  colors: [
                    cs.primary.withOpacity(0.10),
                    cs.primaryContainer.withOpacity(0.06),
                  ],
                )
              : null,
          color: !isDark ? cs.surfaceContainerLowest : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? cs.primary.withOpacity(0.12)
                : cs.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: cs.shadow.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.displayDate,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        summary.dayOfWeek,
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (summary.hasActiveSession) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      // ✅ Semantic orange tint that flips with brightness
                      color: Colors.orange.withOpacity(isDark ? 0.20 : 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: orangeFg,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          TranslationKeys.kickCounterActive.tr,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: orangeFg,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    label: TranslationKeys.kickCounterTotalKicks.tr,
                    value: '${summary.totalKicks}',
                    icon: Icons.favorite_rounded,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatItem(
                    context,
                    label: TranslationKeys.kickCounterHistory.tr,
                    value: '${summary.sessionCount}',
                    icon: Icons.history_rounded,
                    color: cs.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            // ✅ Stronger tint in dark
            color: color.withOpacity(isDark ? 0.22 : 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
