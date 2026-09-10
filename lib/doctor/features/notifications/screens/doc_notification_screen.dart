import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/bottom_nav_bar.dart';
import 'package:doctor/core/widgets/doc_top_app_bar.dart';
import 'package:doctor/doctor/features/notifications/controllers/doc_notification_controller.dart';
import 'package:doctor/doctor/features/notifications/widgets/notification_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorNotificationScreen extends GetView<DoctorNotificationController> {
  const DoctorNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          TopAppNavBar.gradient(
            title: 'Notifications',
            height: 64,
            leadingIcon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.onPrimary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_rounded,
                size: 18,
                color: AppColors.onPrimary,
              ),
            ),
            trailingActions: [
              Obx(() {
                if (controller.unreadCount == 0) return const SizedBox.shrink();
                return Material(
                  color: AppColors.onPrimary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: controller.isMarkingAll.value
                        ? null
                        : controller.markAllAsRead,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: controller.isMarkingAll.value
                          ? SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onPrimary,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.done_all_rounded,
                                  size: 14,
                                  color: AppColors.onPrimary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Mark all read',
                                  style: AppTheme.labelMedium.copyWith(
                                    color: AppColors.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                );
              }),
            ],
          ),
          _buildFilterTabs(),
          Container(height: 1, color: AppColors.outlineSubtle),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.notifications.isEmpty) {
                return _buildLoadingState();
              }

              if (controller.hasError.value) {
                return _buildErrorState();
              }

              if (controller.filteredNotifications.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: controller.refreshNotifications,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : (isDesktop ? 32 : 24),
                    vertical: 16,
                  ),
                  itemCount: controller.filteredNotifications.length + 1,
                  itemBuilder: (context, index) {
                    if (index == controller.filteredNotifications.length) {
                      if (controller.isLoading.value) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }

                    final notification =
                        controller.filteredNotifications[index];
                    return NotificationCard(
                      notification: notification,
                      onTap: () => controller.onNotificationTap(notification),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  // ── Filter tabs ──────────────────────────────────────────────────────────

  // ── Filter tabs ──────────────────────────────────────────────────────────

  Widget _buildFilterTabs() {
    final tabs = <({FilterType filter, String label})>[
      (filter: FilterType.all, label: 'All'),
      (filter: FilterType.unread, label: 'Unread'),
      (filter: FilterType.read, label: 'Read'),
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.outlineSubtle.withOpacity(0.3)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(
          () => Row(
            children: tabs.map((tabData) {
              final selected =
                  controller.selectedFilter.value == tabData.filter;
              final unreadBadge =
                  tabData.filter == FilterType.unread &&
                  controller.unreadCount > 0;

              return GestureDetector(
                onTap: () => controller.setFilter(tabData.filter),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 4,
                  ),
                  margin: const EdgeInsetsDirectional.only(end: 32),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: selected
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tabData.label,
                        style: AppTheme.labelMedium.copyWith(
                          fontSize: 12,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          letterSpacing: 0.05,
                          color: selected
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                      if (unreadBadge) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            controller.unreadCount.toString(),
                            style: AppTheme.labelMedium.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onError,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
  // ── Loading ──────────────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return Center(
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
          const SizedBox(height: 16),
          Text(
            'Loading notifications…',
            style: AppTheme.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ── Error ────────────────────────────────────────────────────────────────

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage.value,
              style: AppTheme.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: controller.refreshNotifications,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
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

  // ── Empty ────────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.primarySubtle,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_rounded,
                size: 40,
                color: AppColors.primaryMuted,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "You're all caught up",
              style: AppTheme.headlineSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No notifications here. Check back later for updates.',
              style: AppTheme.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
