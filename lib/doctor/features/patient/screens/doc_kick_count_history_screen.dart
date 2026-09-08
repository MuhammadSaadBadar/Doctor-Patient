import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/doc_top_app_bar.dart';
import 'package:doctor/doctor/features/patient/controllers/doc_kick_count_history_controller.dart';
import 'package:doctor/doctor/features/patient/models/doc_kick_session.dart';

class DoctorKickCountHistoryScreen
    extends GetView<DoctorKickCountHistoryController> {
  const DoctorKickCountHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Column(
        children: [
          // Top App Bar
          TopAppNavBar.gradient(
            title: 'Kick Count History',
            height: 64,
            showBackButton: true,
            subtitle: 'Patient: ${controller.patientName}',
          ),

          // Main Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.sessions.isEmpty) {
                return _buildLoadingState(context);
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return _buildErrorState(context);
              }

              return RefreshIndicator(
                onRefresh: controller.refreshData,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Patient Context Card
                        _buildPatientContextCard(context),
                        const SizedBox(height: 24),

                        // History List
                        _buildHistoryList(context),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─── Loading State ──────────────────────────────────────────────────────────

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Loading kick count history...',
            style: AppTheme.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Error State ────────────────────────────────────────────────────────────

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
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () => controller.refreshData(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
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

  // ─── Patient Context Card ──────────────────────────────────────────────────

  Widget _buildPatientContextCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final stats = controller.stats.value;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration(context: context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.patientName,
                        style: AppTheme.headlineMedium.copyWith(
                          color: colorScheme.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_rounded,
                            size: 18,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Due Date: ${controller.dueDate}',
                              style: AppTheme.bodySmall.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${controller.week} weeks',
                            style: AppTheme.bodySmall.copyWith(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryFixed,
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(
                      color:
                          colorScheme.secondaryFixedDim ?? Colors.transparent,
                    ),
                  ),
                  child: Text(
                    'Low Risk',
                    style: AppTheme.labelMedium.copyWith(
                      color: colorScheme.onSecondaryFixed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: colorScheme.surfaceContainerHigh, height: 1),
            const SizedBox(height: 16),

            // Stats Grid
            Row(
              children: [
                _buildStatItem(
                  label: 'Total Sessions',
                  value: '${stats.totalSessions}',
                ),
                _buildStatItem(
                  label: 'Total Kicks',
                  value: '${stats.totalKicks}',
                ),
                _buildStatItem(
                  label: 'Average',
                  value: stats.averagePerSession.toStringAsFixed(1),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trend',
                        style: AppTheme.labelMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              stats.trend,
                              style: AppTheme.headlineSmall.copyWith(
                                color: colorScheme.secondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            stats.trend == 'Increasing'
                                ? Icons.trending_up_rounded
                                : stats.trend == 'Decreasing'
                                ? Icons.trending_down_rounded
                                : Icons.trending_flat_rounded,
                            size: 20,
                            color: colorScheme.secondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem({required String label, required String value}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.labelMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTheme.headlineSmall.copyWith(
              color: AppColors.primary, // 🔴 HARDCODED PRIMARY
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  // ─── History List ──────────────────────────────────────────────────────────

  Widget _buildHistoryList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final groupedSessions = controller.groupedSessions;

      if (groupedSessions.isEmpty) {
        return _buildEmptyState(context);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groupedSessions.entries.map((entry) {
          final groupKey = entry.key;
          final sessions = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group Header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  groupKey,
                  style: AppTheme.headlineSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              // Session Cards
              ...sessions.map((session) => _buildSessionCard(context, session)),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      );
    });
  }

  // ─── Session Card ──────────────────────────────────────────────────────────

  Widget _buildSessionCard(BuildContext context, KickSession session) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(session.kickCount);
    final bgColor = _getStatusBackgroundColor(session.kickCount);
    final borderColor = _getStatusBorderColor(session.kickCount);

    return GestureDetector(
      onTap: () => _showSessionDetails(context, session),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Center(
                child: Text(
                  '${session.kickCount}',
                  style: AppTheme.headlineMedium.copyWith(
                    color: AppColors.primary, // 🔴 HARDCODED PRIMARY
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.displayTime,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppColors.primary, // 🔴 HARDCODED PRIMARY
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    '${session.displayDuration}',
                    style: AppTheme.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),

            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.child_care_rounded,
                size: 36,
                color: colorScheme.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No kick count sessions yet',
              style: AppTheme.titleMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Patient hasn\'t logged any kick tracking sessions',
              style: AppTheme.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Session Details Bottom Sheet ────────────────────────────────────────

  void _showSessionDetails(BuildContext context, KickSession session) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            const SizedBox(height: 8),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Session Details',
                    style: AppTheme.headlineMedium.copyWith(
                      color: AppColors.primary, // 🔴 HARDCODED PRIMARY
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Grid
                  Row(
                    children: [
                      _buildDetailStat(
                        label: 'Total kicks',
                        value: '${session.kickCount}',
                      ),
                      _buildDetailStat(
                        label: 'Duration',
                        value: session.displayDuration,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildDetailStat(
                        label: 'Start/End',
                        value: session.displayTime,
                        fontSize: 14,
                      ),
                      _buildDetailStat(
                        label: 'Kicks/min',
                        value: session.durationMinutes > 0
                            ? (session.kickCount / session.durationMinutes)
                                  .toStringAsFixed(1)
                            : 'N/A',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Notes (if any)
                  if (session.notes != null && session.notes!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Patient notes',
                            style: AppTheme.labelMedium.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            session.notes!,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppColors
                                  .primary, // 🔴 NOTES - HARDCODED PRIMARY
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailStat({
    required String label,
    required String value,
    double fontSize = 16,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.labelMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.primary, // 🔴 HARDCODED PRIMARY
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  // ─── Helper Methods ──────────────────────────────────────────────────────

  Color _getStatusColor(int kickCount) {
    if (kickCount >= 10) return const Color(0xFF137333);
    if (kickCount >= 5) return const Color(0xFFEA8600);
    return const Color(0xFFBA1A1A);
  }

  Color _getStatusBackgroundColor(int kickCount) {
    if (kickCount >= 10) return const Color(0xFFE6F4EA);
    if (kickCount >= 5) return const Color(0xFFFEF7E0);
    return const Color(0xFFFFDAD6);
  }

  Color _getStatusBorderColor(int kickCount) {
    if (kickCount >= 10) return const Color(0xFFA8DAB5);
    if (kickCount >= 5) return const Color(0xFFFDE293);
    return const Color(0xFFFFB4AB);
  }
}
