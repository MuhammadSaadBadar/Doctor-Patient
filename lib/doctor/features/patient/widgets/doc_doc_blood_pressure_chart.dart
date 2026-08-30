import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';
import 'package:doctor/doctor/features/patient/models/doc_patient.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BloodPressureChart extends StatelessWidget {
  final Patient? patient;
  final List<Map<String, dynamic>> history;
  final int? patientId;
  final VoidCallback? onHistoryPressed;

  const BloodPressureChart({
    super.key,
    this.patient,
    this.history = const [],
    this.patientId,
    this.onHistoryPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final listHeight = (screenHeight * 0.35).clamp(240.0, 320.0);

    // Handle null patient
    if (patient == null) {
      return Container(
        height: listHeight,
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: AppTheme.cardDecoration(context: context),
        child: const Center(
          child: Text(
            'No patient data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Sort history by date (most recent first)
    final sortedHistory = List<Map<String, dynamic>>.from(history);
    sortedHistory.sort((a, b) {
      final dateA = DateTime.tryParse(a['recorded_at']?.toString() ?? '');
      final dateB = DateTime.tryParse(b['recorded_at']?.toString() ?? '');
      if (dateA == null || dateB == null) return 0;
      return dateB.compareTo(dateA);
    });

    return Container(
      height: listHeight,
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Fixed Row structure
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
                  Icons.monitor_heart_rounded,
                  size: 15,
                  color: AppColors.onPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Blood Pressure',
                  style: AppTheme.headlineSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 8),
              // History button
              if (patientId != null)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap:
                        onHistoryPressed ??
                        () => Get.toNamed(
                          AppRoutes.docbloodPressureHistory,
                          arguments: {'patientId': patientId},
                        ),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'View all',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.surfaceContainerLow,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    patient!.bloodPressure ?? '—',
                    style: AppTheme.headlineMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    patient!.latestReading ?? '—',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Builder(
              builder: (context) {
                if (sortedHistory.isEmpty) {
                  return const Center(
                    child: Text(
                      'No history available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: sortedHistory.length,
                  itemBuilder: (context, index) {
                    final entry = sortedHistory[index];
                    final systolic = entry['systolic']?.toString() ?? '—';
                    final diastolic = entry['diastolic']?.toString() ?? '—';
                    final date = DateTime.tryParse(
                      entry['recorded_at']?.toString() ?? '',
                    );

                    // Determine BP category
                    final double? systolicValue = (entry['systolic'] as num?)
                        ?.toDouble();
                    final double? diastolicValue = (entry['diastolic'] as num?)
                        ?.toDouble();

                    final String category = _getBPCategory(
                      systolicValue ?? 0,
                      diastolicValue ?? 0,
                    );
                    final Color categoryColor = _getCategoryColor(category);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getCategoryIcon(category),
                            size: 18,
                            color: categoryColor,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              '$systolic/$diastolic',
                              style: AppTheme.titleMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'mmHg',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          category,
                          style: AppTheme.bodySmall.copyWith(
                            color: categoryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: Text(
                          _formatDate(date),
                          style: AppTheme.labelMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildLegendDot('Normal', AppColors.primary),
              const SizedBox(width: 12),
              _buildLegendDot('Elevated', Colors.orange),
              const SizedBox(width: 12),
              _buildLegendDot('High', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  String _getBPCategory(double systolic, double diastolic) {
    if (systolic >= 140 || diastolic >= 90) {
      return 'High';
    } else if (systolic >= 120 || diastolic >= 80) {
      return 'Elevated';
    } else {
      return 'Normal';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'High':
        return Colors.red;
      case 'Elevated':
        return Colors.orange;
      case 'Normal':
      default:
        return AppColors.primary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'High':
        return Icons.warning_rounded;
      case 'Elevated':
        return Icons.trending_up_rounded;
      case 'Normal':
      default:
        return Icons.check_circle_rounded;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  Widget _buildLegendDot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
