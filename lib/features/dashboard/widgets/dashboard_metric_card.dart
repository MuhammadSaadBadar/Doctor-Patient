import 'package:doctor/core/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/features/dashboard/models/dashboard_metric.dart';

class DashboardMetricCard extends StatelessWidget {
  final DashboardMetric metric;
  final VoidCallback? onTap;

  const DashboardMetricCard({super.key, required this.metric, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cardColor =
        Theme.of(context).cardTheme.color ??
        Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    final outlineVariant = Theme.of(context).colorScheme.outlineVariant;

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: outlineVariant, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Label at the top
              Text(
                metric.label,
                style: AppTheme.bodySmall.copyWith(color: onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Value below
              Text(
                metric.value,
                style: AppTheme.headlineMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
