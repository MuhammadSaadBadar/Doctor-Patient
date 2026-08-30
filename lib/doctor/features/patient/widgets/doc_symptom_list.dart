import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/doctor/features/patient/models/doc_symptom.dart';
import 'package:flutter/material.dart';

class SymptomList extends StatelessWidget {
  final List<Symptom> symptoms;
  final bool isLoading;

  const SymptomList({
    super.key,
    required this.symptoms,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // ADD THIS - ensures bounded width
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Fixed: Removed nested Row, use Expanded directly
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sick_rounded,
                  size: 15,
                  color: AppColors.onPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                // Use Expanded for the title
                child: Text(
                  'Recent Symptoms',
                  style: AppTheme.headlineSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // const SizedBox(width: 8), // Add spacing
              // Material(
              //   color: AppColors.primaryContainer,
              //   borderRadius: BorderRadius.circular(8),
              //   child: InkWell(
              //     borderRadius: BorderRadius.circular(8),
              //     onTap: () {},
              //     child: Padding(
              //       padding: const EdgeInsets.symmetric(
              //         horizontal: 8,
              //         vertical: 4,
              //       ),
              //       child: Text(
              //         'View All',
              //         style: AppTheme.bodySmall.copyWith(
              //           color: AppColors.onPrimary,
              //           fontWeight: FontWeight.w700,
              //           fontSize: 11,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.surfaceVariant, width: 1),
              ),
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else if (symptoms.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 28,
                      color: AppColors.outline,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'No symptoms logged',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...symptoms.map((symptom) => _buildSymptomItem(symptom)),
        ],
      ),
    );
  }

  Widget _buildSymptomItem(Symptom symptom) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceVariant, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color: symptom.severityColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symptom.name,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'Logged: ${symptom.date}',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (symptom.notes != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    symptom.notes!,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Removed Flexible wrapper, just use the Container directly
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: symptom.severityColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              symptom.severityDisplay,
              style: AppTheme.labelMedium.copyWith(
                color: symptom.severityTextColor,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
