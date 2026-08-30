// lib/features/patient/screens/blood_pressure_history_screen.dart

import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/bottom_nav_bar.dart';
import 'package:doctor/core/widgets/top_app_bar.dart';
import 'package:doctor/doctor/features/patient/controllers/doc_blood_pressure_history_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DoctorBloodPressureHistoryScreen
    extends GetView<DoctorBloodPressureHistoryController> {
  const DoctorBloodPressureHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Column(
        children: [
          TopAppNavBar.gradient(
            title: 'BP History',
            showBackButton: true,
            height: 64,
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState(context);
              }

              if (controller.hasError.value) {
                return _buildErrorState(context);
              }

              if (controller.readings.isEmpty) {
                return _buildEmptyState(context);
              }

              return RefreshIndicator(
                onRefresh: () async => controller.refresh(),
                color: colorScheme.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      ...controller.groupedReadings.entries.map((entry) {
                        return _buildHistoryGroup(
                          context,
                          colorScheme,
                          entry.key,
                          entry.value,
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Loading blood pressure history...',
            style: AppTheme.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage.value,
              style: AppTheme.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () => controller.refresh(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryGroup(
    BuildContext context,
    ColorScheme colorScheme,
    String title,
    List<Map<String, dynamic>> readings,
  ) {
    if (readings.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            title,
            style: AppTheme.headlineSmall.copyWith(
              color: colorScheme.secondary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...readings.map(
          (reading) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildReadingCard(context, colorScheme, reading),
          ),
        ),
      ],
    );
  }

  Widget _buildReadingCard(
    BuildContext context,
    ColorScheme colorScheme,
    Map<String, dynamic> reading,
  ) {
    final systolic = reading['systolic'] as int? ?? 0;
    final diastolic = reading['diastolic'] as int? ?? 0;
    final pulse = reading['pulse'] as int?;
    final recordedAt = DateTime.tryParse(
      reading['recorded_at']?.toString() ?? '',
    );
    final notes = reading['notes'] as String? ?? '';

    final statusLabel = controller.getStatusLabel(systolic, diastolic);
    final statusColor = controller.getStatusColor(statusLabel);
    final statusBgColor = controller.getStatusBackgroundColor(statusLabel);
    final statusIcon = controller.getStatusIcon(statusLabel);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDetailsSheet(context, colorScheme, reading),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.cardDecoration(context: context),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            '$systolic',
                            style: AppTheme.headlineMedium.copyWith(
                              color: AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            '/$diastolic',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'mmHg',
                            style: AppTheme.labelMedium.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.favorite_rounded,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '$statusLabel${pulse != null ? ' • $pulse bpm' : ''}',
                            style: AppTheme.bodyMedium.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        notes,
                        style: AppTheme.bodySmall.copyWith(
                          color:
                              AppColors.primary, // 🔴 NOTES - HARDCODED PRIMARY
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    recordedAt != null
                        ? DateFormat('hh:mm a').format(recordedAt)
                        : '--:--',
                    style: AppTheme.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.outline,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite_outline_rounded,
                  size: 56,
                  color: colorScheme.primary.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Blood Pressure Records',
                style: AppTheme.headlineMedium.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'This patient has no blood pressure readings recorded yet.',
                  style: AppTheme.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetailsSheet(
    BuildContext context,
    ColorScheme colorScheme,
    Map<String, dynamic> reading,
  ) {
    final systolic = reading['systolic'] as int? ?? 0;
    final diastolic = reading['diastolic'] as int? ?? 0;
    final pulse = reading['pulse'] as int?;
    final recordedAt = DateTime.tryParse(
      reading['recorded_at']?.toString() ?? '',
    );
    final notes = reading['notes'] as String? ?? '';

    final statusLabel = controller.getStatusLabel(systolic, diastolic);
    final statusColor = controller.getStatusColor(statusLabel);
    final statusBgColor = controller.getStatusBackgroundColor(statusLabel);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              blurRadius: 30,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 48,
                  height: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reading Details',
                              style: AppTheme.headlineMedium.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              recordedAt != null
                                  ? DateFormat(
                                      'MMM d, yyyy • hh:mm a',
                                    ).format(recordedAt)
                                  : 'Unknown date',
                              style: AppTheme.bodyMedium.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: colorScheme.surfaceContainerLow,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Blood Pressure',
                                  style: AppTheme.labelMedium.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        '$systolic',
                                        style: AppTheme.headlineLarge.copyWith(
                                          color: AppColors.primary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Flexible(
                                      child: Text(
                                        '/$diastolic',
                                        style: AppTheme.headlineMedium.copyWith(
                                          color: AppColors.primary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        'mmHg',
                                        style: AppTheme.labelMedium.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              controller.getStatusIcon(statusLabel),
                              color: statusColor,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        if (pulse != null)
                          Expanded(
                            child: _buildStatItem(
                              context,
                              colorScheme,
                              label: 'Pulse',
                              value: '$pulse',
                              unit: 'bpm',
                            ),
                          ),
                        if (pulse != null) const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            colorScheme,
                            label: 'Status',
                            value: statusLabel,
                            valueColor: statusColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (notes.isNotEmpty) ...[
                      Text(
                        'Notes',
                        style: AppTheme.labelMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.outlineVariant.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          notes,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppColors
                                .primary, // 🔴 NOTES - HARDCODED PRIMARY
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    ColorScheme colorScheme, {
    required String label,
    required String value,
    String? unit,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.labelMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: AppTheme.headlineSmall.copyWith(
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    unit,
                    style: AppTheme.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
