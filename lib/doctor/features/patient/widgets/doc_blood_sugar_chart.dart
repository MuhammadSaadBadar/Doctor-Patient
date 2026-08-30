import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/doctor/features/patient/models/doc_patient.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BloodSugarChart extends StatelessWidget {
  final Patient? patient;
  final List<Map<String, dynamic>> history;
  final String? filterContext; // 'fasting', 'post_meal', or null for all
  final int? patientId;
  final VoidCallback? onHistoryPressed;

  const BloodSugarChart({
    super.key,
    this.patient,
    this.history = const [],
    this.filterContext,
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

    // Filter history by reading context if specified
    final filteredHistory = filterContext != null
        ? history.where((e) => e['reading_context'] == filterContext).toList()
        : history;

    // Sort by date (most recent first)
    filteredHistory.sort((a, b) {
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
          // Header
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
                  Icons.water_drop_rounded,
                  size: 15,
                  color: AppColors.onPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Blood Sugar',
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
                          AppRoutes.docbloodSugarHistory,
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
                    '${_getDisplayValue(filteredHistory)}',
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
                    _getContextLabel(filteredHistory),
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
                if (filteredHistory.isEmpty) {
                  return const Center(
                    child: Text(
                      'No history available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredHistory.length,
                  itemBuilder: (context, index) {
                    final entry = filteredHistory[index];
                    final value = entry['value_mg_dl']?.toString() ?? '0';
                    final date = DateTime.tryParse(
                      entry['recorded_at']?.toString() ?? '',
                    );
                    final contextLabel = _getReadingContextLabel(
                      entry['reading_context'] as String?,
                    );
                    // Fixed: properly parse the value and compare
                    final double? bloodSugarValue =
                        (entry['value_mg_dl'] as num?)?.toDouble();
                    final bool isAboveTarget = (bloodSugarValue ?? 0) > 100;

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
                            color: isAboveTarget
                                ? Colors.orange.withOpacity(0.1)
                                : AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isAboveTarget
                                ? Icons.arrow_upward_rounded
                                : Icons.check_rounded,
                            size: 18,
                            color: isAboveTarget
                                ? Colors.orange
                                : AppColors.primary,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              value,
                              style: AppTheme.titleMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isAboveTarget
                                    ? Colors.orange
                                    : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'mg/dL',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          contextLabel,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 11,
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
        ],
      ),
    );
  }

  String _getDisplayValue(List<Map<String, dynamic>> history) {
    if (history.isEmpty) return '0';
    // Get the most recent value
    return history.first['value_mg_dl']?.toString() ?? '0';
  }

  String _getContextLabel(List<Map<String, dynamic>> history) {
    if (history.isEmpty) return 'mg/dL';

    final context = history.first['reading_context'] as String?;
    switch (context) {
      case 'fasting':
        return 'mg/dL (Latest)';
      case 'post_meal':
        return 'mg/dL (Latest)';
      case 'random':
        return 'mg/dL (Latest)';
      default:
        return 'mg/dL (Latest)';
    }
  }

  String _getReadingContextLabel(String? context) {
    switch (context) {
      case 'fasting':
        return 'Fasting';
      case 'post_meal':
        return 'Post-meal';
      case 'random':
        return 'Random';
      default:
        return 'Unknown';
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
}
