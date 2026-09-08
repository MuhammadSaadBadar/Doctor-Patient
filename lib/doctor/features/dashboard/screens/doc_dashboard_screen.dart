// lib/features/dashboard/screens/dashboard_screen.dart

import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/bottom_nav_bar.dart';
import 'package:doctor/core/widgets/doctor_avatar.dart';
import 'package:doctor/core/widgets/side_nav.dart';
import 'package:doctor/core/widgets/doc_top_app_bar.dart';
import 'package:doctor/doctor/features/dashboard/controllers/doc_dashboard_controller.dart';
import 'package:doctor/doctor/features/dashboard/models/doc_dashboard_alert.dart';
import 'package:doctor/doctor/features/dashboard/widgets/alert_card.dart';
import 'package:doctor/doctor/features/dashboard/widgets/appointment_tile.dart';
import 'package:doctor/doctor/features/dashboard/widgets/dashboard_hero_stat.dart';
import 'package:doctor/doctor/features/dashboard/widgets/dashboard_metric_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorDashboardScreen extends GetView<DoctorDashboardController> {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Row(
        children: [
          if (isDesktop) const SideNav(currentRoute: '/dashboard'),
          Expanded(
            child: Column(
              children: [
                Obx(
                  () => TopAppNavBar.gradient(
                    title: 'Dashboard',
                    height: 64,
                    onNotificationTap: () =>
                        Get.toNamed(AppRoutes.docnotifications),
                    notificationCount: controller.unreadNotificationCount.value,
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const _LoadingState();
                    }

                    if (controller.hasError.value) {
                      return _ErrorState(
                        message: controller.errorMessage.value,
                        onRetry: controller.refreshDashboard,
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.primary,
                      backgroundColor: AppColors.surfaceContainerLowest,
                      onRefresh: () async => controller.refreshDashboard(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.only(
                          left: isDesktop ? 32.0 : 16.0,
                          right: isDesktop ? 32.0 : 16.0,
                          top: 0,
                          bottom: 32.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 14),
                            _buildWelcomeBanner(context),
                            const SizedBox(height: 20),
                            _buildHeroStats(context),
                            const SizedBox(height: 9),
                            _buildMetricsGrid(context),
                            const SizedBox(height: 20),
                            _buildMainContent(context, isDesktop, isTablet),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  // ── Welcome banner ──────────────────────────────────────────────────────────

  Widget _buildWelcomeBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.onPrimary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.onPrimary.withOpacity(0.15),
                    ),
                  ),
                  child: Text(
                    _formattedDate(),
                    style: AppTheme.labelSmall.copyWith(
                      color: AppColors.onPrimary.withOpacity(0.80),
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Obx(
                  () => Text(
                    'Welcome Back,\n${controller.doctorName.value}',
                    style: AppTheme.headlineLargeMobile.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Here is an overview of your day.',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppColors.onPrimary.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Reactive avatar showing doctor's profile image
          DoctorAvatar(
            imageUrl: controller.doctorImageUrl.value,
            firstName: controller.doctorName.value
                .replaceFirst('Dr. ', '')
                .split(' ')
                .first,
            size: 56,
            enableCacheBusting: true,
          ),
        ],
      ),
    );
  }

  // ── Hero stats ──────────────────────────────────────────────────────────────

  Widget _buildHeroStats(BuildContext context) {
    return Obx(() {
      final totalPatientsMetric = controller.metrics.firstWhereOrNull(
        (m) => m.label.toLowerCase().contains('total patient'),
      );
      final ratingMetric = controller.metrics.firstWhereOrNull(
        (m) => m.label.toLowerCase().contains('rating'),
      );

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (totalPatientsMetric != null)
            DashboardHeroStat(
              iconName: totalPatientsMetric.iconName,
              label: totalPatientsMetric.label,
              value: totalPatientsMetric.value,
              onTap: () => Get.toNamed('/patients'),
            ),
          if (totalPatientsMetric != null && ratingMetric != null)
            const SizedBox(height: 12),
          if (ratingMetric != null)
            DashboardHeroStat(
              iconName: ratingMetric.iconName,
              label: ratingMetric.label,
              value: ratingMetric.value,
            ),
        ],
      );
    });
  }

  // ── Metrics grid ────────────────────────────────────────────────────────────

  Widget _buildMetricsGrid(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Obx(() {
      final gridMetrics = controller.metrics.where((m) {
        final label = m.label.toLowerCase();
        return !label.contains('total patient') && !label.contains('rating');
      }).toList();

      if (gridMetrics.isEmpty) {
        return const SizedBox.shrink();
      }

      int crossAxisCount;
      double childAspectRatio;

      if (isDesktop) {
        crossAxisCount = 4;
        childAspectRatio = 1.6;
      } else if (isTablet) {
        crossAxisCount = 3;
        childAspectRatio = 1.5;
      } else {
        crossAxisCount = 2;
        childAspectRatio = 1.4;
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: gridMetrics.length,
        itemBuilder: (context, index) {
          final metric = gridMetrics[index];
          return DashboardMetricCard(
            metric: metric,
            onTap: metric.id == '8'
                ? () => Get.toNamed(AppRoutes.docsos)
                : null,
          );
        },
      );
    });
  }

  // ── Main content ────────────────────────────────────────────────────────────

  Widget _buildMainContent(
    BuildContext context,
    bool isDesktop,
    bool isTablet,
  ) {
    if (isDesktop) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 8, child: _buildScheduleCard(context)),
            const SizedBox(width: 20),
            Expanded(flex: 4, child: _buildAlertsCard(context)),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 14),
        _buildScheduleCard(context),
        const SizedBox(height: 16),
        _buildAlertsCard(context),
      ],
    );
  }

  // ── Schedule card ───────────────────────────────────────────────────────────

  Widget _buildScheduleCard(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(context: context),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primarySubtle,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Today's Schedule",
                        style: AppTheme.headlineSmall.copyWith(
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: TextButton(
                  onPressed: () => Get.toNamed('/appointments'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: AppTheme.labelMedium.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Container(height: 1, color: AppColors.outlineSubtle),
          const SizedBox(height: 14),

          Obx(() {
            if (controller.appointments.isEmpty) {
              return const _EmptySlot(
                icon: Icons.event_available_rounded,
                message: 'No appointments today',
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: controller.appointments
                  .map(
                    (appt) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppointmentTile(
                        appointment: appt,
                        onTap: () => Get.toNamed(
                          '/appointment-detail',
                          arguments: appt.id,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          }),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => Get.toNamed('/appointments'),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.primarySubtle,
                foregroundColor: AppColors.primary,
                elevation: 0,
                side: BorderSide(color: AppColors.outlineSubtle, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: AppTheme.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('View All Appointments'),
            ),
          ),
        ],
      ),
    );
  }

  // ── Alerts card ─────────────────────────────────────────────────────────────

  Widget _buildAlertsCard(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(context: context),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.notifications_active_rounded,
                        size: 16,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Action Needed',
                        style: AppTheme.headlineSmall.copyWith(
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Obx(() {
                  if (controller.alerts.isEmpty) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${controller.alerts.length}',
                      style: AppTheme.labelMedium.copyWith(
                        color: AppColors.onErrorContainer,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Container(height: 1, color: AppColors.outlineSubtle),
          const SizedBox(height: 14),

          Obx(() {
            if (controller.alerts.isEmpty) {
              return const _EmptySlot(
                icon: Icons.task_alt_rounded,
                message: "You're all caught up",
                iconColor: AppColors.success,
                iconBg: AppColors.successSubtle,
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: controller.alerts
                  .map(
                    (alert) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AlertCard(
                        alert: alert,
                        onAction: () {
                          if (alert.type == AlertType.urgent) {
                            // Navigate to patient details or lab results
                          } else if (alert.type == AlertType.pending) {
                            // Navigate to pending approvals
                          } else {
                            Get.snackbar(
                              'Info',
                              '${alert.actionText} functionality coming soon',
                              snackPosition: SnackPosition.TOP,
                            );
                          }
                        },
                      ),
                    ),
                  )
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
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
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}

// ── Extracted state widgets ────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.outlineSubtle,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Loading dashboard…',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Something went wrong',
              style: AppTheme.titleLarge.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTheme.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color? iconColor;
  final Color? iconBg;

  const _EmptySlot({
    required this.icon,
    required this.message,
    this.iconColor,
    this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBg ?? AppColors.primarySubtle,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: iconColor ?? AppColors.primaryMuted,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: AppTheme.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
