// lib/features/patient/widgets/patient_card_widget.dart

import 'package:doctor/core/constants/app_dimensions.dart';
import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart' show AppTheme;
import 'package:doctor/features/patient/models/patient_card.dart';
import 'package:flutter/material.dart';

class PatientCardWidget extends StatelessWidget {
  final PatientCard patient;
  final VoidCallback onTap;

  const PatientCardWidget({
    super.key,
    required this.patient,
    required this.onTap,
  });

  bool get _isHighRisk => patient.status == PatientStatus.highRisk;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 0,
        vertical: AppDimensions.cardVerticalMargin,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.cardPadding),
            decoration:
                AppTheme.cardDecoration(
                  context: context,
                  hasBorder: true,
                  hasShadow: true,
                ).copyWith(
                  border: Border.all(
                    color: _isHighRisk
                        ? colorScheme.error.withOpacity(0.3)
                        : colorScheme.outlineVariant.withOpacity(0.6),
                    width: 1,
                  ),
                ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // === HEADER ROW ===
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: AppDimensions.avatarSize,
                      height: AppDimensions.avatarSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: _isHighRisk
                            ? Border.all(color: colorScheme.error, width: 2)
                            : null,
                      ),
                      child: CircleAvatar(
                        radius: AppDimensions.avatarSize / 2,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          patient.initials,
                          style: AppTheme.titleMedium.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                            fontSize: isMobile ? 15 : 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name & ID
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  patient.fullName,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: isMobile ? 15 : 17,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_isHighRisk)
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  margin: const EdgeInsets.only(left: 6),
                                  decoration: BoxDecoration(
                                    color: colorScheme.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.priority_high_rounded,
                                    size: 10,
                                    color: colorScheme.onError,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 1),
                          Text(
                            patient.patientId,
                            style: AppTheme.bodySmall.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                              fontSize: isMobile ? 11 : 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.sectionSpacing),

                // === DIVIDER ===
                Container(
                  height: AppDimensions.dividerHeight,
                  color: colorScheme.outlineVariant.withOpacity(0.5),
                ),

                const SizedBox(height: AppDimensions.sectionSpacing),

                // === PROGRESS & NEXT VISIT ROW (Dual Column) ===
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Progress',
                        patient.week,
                        isMobile,
                        isHighlight: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Next Visit',
                        patient.nextVisit,
                        isMobile,
                        isHighlight: patient.status == PatientStatus.highRisk,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // === STATUS BADGE ROW ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [_buildStatusBadge(context, isMobile)],
                ),

                const SizedBox(height: 6),

                // === VIEW DETAILS BUTTON (Matching AppointmentCard) ===
                SizedBox(
                  width: double.infinity,
                  height: AppDimensions.ctaButtonHeight,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: AppTheme.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: isMobile ? 11 : 12,
                      ),
                    ),
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool isMobile) {
    final colorScheme = Theme.of(context).colorScheme;
    final status = patient.status;

    Color bgColor;
    Color dotColor;
    Color textColor;

    switch (status) {
      case PatientStatus.highRisk:
        bgColor = colorScheme.errorContainer;
        dotColor = colorScheme.error;
        textColor = colorScheme.onErrorContainer;
        break;
      case PatientStatus.monitoring:
        bgColor = colorScheme.tertiaryContainer;
        dotColor = colorScheme.tertiary;
        textColor = colorScheme.onTertiaryContainer;
        break;
      case PatientStatus.stable:
        bgColor = colorScheme.secondaryContainer;
        dotColor = colorScheme.secondary;
        textColor = colorScheme.onSecondaryContainer;
        break;
      case null:
        bgColor = colorScheme.surfaceContainerHigh;
        dotColor = colorScheme.outline;
        textColor = colorScheme.onSurfaceVariant;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            patient.statusDisplay,
            style: AppTheme.labelMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: isMobile ? 9 : 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    bool isMobile, {
    bool isHighlight = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTheme.labelMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: isMobile ? 9 : 10,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: AppTheme.bodySmall.copyWith(
            color: AppColors.primary, // Hardcoded to AppColors.primary
            fontWeight: FontWeight.w700,
            fontSize: isMobile ? 12 : 13,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
