import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:flutter/material.dart';

class PregnancyProgressCard extends StatelessWidget {
  final String? lmpDate;
  final String? eddDate;
  final int? currentWeek;
  final int? currentDay;
  final double? percentComplete;
  final int? trimester;
  final int? daysRemaining;

  const PregnancyProgressCard({
    super.key,
    this.lmpDate,
    this.eddDate,
    this.currentWeek,
    this.currentDay,
    this.percentComplete,
    this.trimester,
    this.daysRemaining,
  });

  factory PregnancyProgressCard.fromPatientSummary({
    required String? lmpDate,
    required String? eddDate,
    required int? currentWeek,
    required int? currentDay,
    required double? percentComplete,
    required int? trimester,
    required int? daysRemaining,
  }) {
    return PregnancyProgressCard(
      lmpDate: lmpDate,
      eddDate: eddDate,
      currentWeek: currentWeek,
      currentDay: currentDay,
      percentComplete: percentComplete,
      trimester: trimester,
      daysRemaining: daysRemaining,
    );
  }

  String get trimesterDisplay {
    switch (trimester) {
      case 1:
        return '1st Trimester';
      case 2:
        return '2nd Trimester';
      case 3:
        return '3rd Trimester';
      default:
        return 'Unknown';
    }
  }

  String get formattedEdd {
    try {
      if (eddDate == null) return 'Unknown';
      final date = DateTime.parse(eddDate!);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return eddDate ?? 'Unknown';
    }
  }

  String get formattedLmp {
    try {
      if (lmpDate == null) return 'Unknown';
      final date = DateTime.parse(lmpDate!);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return lmpDate ?? 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasData = currentWeek != null && currentWeek! > 0;

    if (!hasData) {
      return const SizedBox.shrink();
    }

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
                  color: AppColors.secondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pregnant_woman_rounded,
                  size: 18,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pregnancy Progress',
                  style: AppTheme.headlineSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    trimesterDisplay,
                    style: AppTheme.labelMedium.copyWith(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Week ${currentWeek}',
                    style: AppTheme.headlineMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (daysRemaining != null)
                    Text(
                      '${daysRemaining} days remaining',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'EDD',
                    style: AppTheme.labelMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    formattedEdd,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (percentComplete ?? 0) / 100,
              minHeight: 8,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LMP: $formattedLmp',
                style: AppTheme.labelMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                '${percentComplete?.toStringAsFixed(0) ?? 0}%',
                style: AppTheme.labelMedium.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}