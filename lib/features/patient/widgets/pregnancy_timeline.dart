import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/features/patient/models/patient.dart';
import 'package:flutter/material.dart';

class PregnancyTimeline extends StatelessWidget {
  final Patient? patient;

  const PregnancyTimeline({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    // Handle null patient
    if (patient == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration(context: context),
        child: const Center(
          child: Text(
            'No patient data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Parse week from 'Week X' string
    int currentWeek = 0;
    final weekStr = patient!.week;
    if (weekStr.startsWith('Week ')) {
      currentWeek = int.tryParse(weekStr.substring(5)) ?? 0;
    }

    // Handle missing weight gain
    final weightGain = patient!.weightGain ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.timeline_rounded,
                  size: 16,
                  color: AppColors.onPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Progress & Weight Gain',
                style: AppTheme.headlineSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.surfaceContainerLow, height: 1),
          const SizedBox(height: 20),
          // Timeline
          SizedBox(
            height: 100,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Progress percentage (max 40 weeks)
                double progress = (currentWeek / 40.0).clamp(0.0, 1.0);

                bool trim1Done = currentWeek >= 13;
                bool trim2Done = currentWeek >= 27;

                return Stack(
                  children: [
                    Positioned(
                      top: 28,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 28,
                      left: 0,
                      width: constraints.maxWidth * progress,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTimelineItem('Trim 1', trim1Done, currentWeek > 0 && currentWeek < 13),
                        _buildTimelineItem('Trim 2', trim2Done, currentWeek >= 13 && currentWeek < 27),
                        _buildTimelineItem(patient!.week, currentWeek > 0, currentWeek >= 27 && currentWeek < 40),
                        _buildTimelineItem('Term', currentWeek >= 40, currentWeek >= 40),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total weight gain',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${weightGain.toStringAsFixed(0)} lbs',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String label, bool isActive, bool isCurrent) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isCurrent ? 22 : 16,
          height: isCurrent ? 22 : 16,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.surfaceVariant,
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(color: Colors.white, width: 3)
                : null,
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: isActive && !isCurrent
              ? const Icon(Icons.check, size: 10, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: isCurrent
              ? AppTheme.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                )
              : AppTheme.labelMedium.copyWith(
                  color: isActive
                      ? AppColors.onSurface
                      : AppColors.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
        ),
      ],
    );
  }
}
