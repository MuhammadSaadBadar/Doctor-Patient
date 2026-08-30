// lib/features/notifications/controllers/notification_controller.dart

import 'package:doctor/doctor/features/dashboard/controllers/doc_dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/doctor/features/notifications/models/doc_notification.dart';
import 'package:doctor/doctor/features/notifications/repositories/doc_notification_repository.dart';

// Move FilterType outside the controller class
enum FilterType { all, unread, read }

class DoctorNotificationController extends GetxController {
  final DoctorNotificationRepository _repository =
      DoctorNotificationRepository();

  // State
  final notifications = <NotificationModel>[].obs;
  final filteredNotifications = <NotificationModel>[].obs;
  final isLoading = true.obs;
  final isMarkingAll = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Filter - FIXED: Use Rx<FilterType> and access .value properly
  final selectedFilter = FilterType.all.obs;

  // Pagination
  int _currentPage = 1;
  bool _hasMoreData = true;
  static const int _pageSize = 20;

  // Computed
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  String get filterLabel {
    switch (selectedFilter.value) {
      case FilterType.all:
        return 'All';
      case FilterType.unread:
        return 'Unread';
      case FilterType.read:
        return 'Read';
    }
  }

  String get filterBadge {
    if (selectedFilter.value == FilterType.unread && unreadCount > 0) {
      return unreadCount.toString();
    }
    return '';
  }

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  Future<void> _loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      notifications.clear();
    }

    if (!_hasMoreData) return;

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await _repository.getNotifications(
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (refresh) {
        notifications.value = result.notifications;
      } else {
        notifications.addAll(result.notifications);
      }

      _hasMoreData = result.hasNext;
      _currentPage++;

      _applyFilter();

      debugPrint('[NOTIFICATION] Loaded ${notifications.length} notifications');
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load notifications. Please try again.';
      debugPrint('[NOTIFICATION] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilter() {
    switch (selectedFilter.value) {
      case FilterType.all:
        filteredNotifications.value = List.from(notifications);
        break;
      case FilterType.unread:
        filteredNotifications.value = notifications
            .where((n) => !n.isRead)
            .toList();
        break;
      case FilterType.read:
        filteredNotifications.value = notifications
            .where((n) => n.isRead)
            .toList();
        break;
    }
  }

  void setFilter(FilterType filter) {
    selectedFilter.value = filter;
    _applyFilter();
  }

  Future<void> refreshNotifications() async {
    await _loadNotifications(refresh: true);
  }

  Future<void> loadMore() async {
    if (!isLoading.value && _hasMoreData) {
      await _loadNotifications();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final success = await _repository.markAsRead(notificationId);
    if (success) {
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final updated = notifications[index];
        notifications[index] = NotificationModel(
          id: updated.id,
          type: updated.type,
          title: updated.title,
          body: updated.body,
          data: updated.data,
          isRead: true,
          channelPushSent: updated.channelPushSent,
          channelWhatsappSent: updated.channelWhatsappSent,
          createdAt: updated.createdAt,
        );
        notifications.refresh();
        _applyFilter();
      }
      // Refresh dashboard unread count
      try {
        Get.find<DoctorDashboardController>().refreshUnreadCount();
      } catch (_) {
        // DashboardController not initialized yet
      }
    }
  }

  Future<void> markAllAsRead() async {
    if (unreadCount == 0) return;

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Mark All as Read',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        content: Text(
          'Are you sure you want to mark all $unreadCount notifications as read?',
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Mark All Read',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    isMarkingAll.value = true;

    try {
      final count = await _repository.markAllAsRead();
      if (count > 0) {
        // Update all notifications to read
        final updatedNotifications = notifications.map((n) {
          return NotificationModel(
            id: n.id,
            type: n.type,
            title: n.title,
            body: n.body,
            data: n.data,
            isRead: true,
            channelPushSent: n.channelPushSent,
            channelWhatsappSent: n.channelWhatsappSent,
            createdAt: n.createdAt,
          );
        }).toList();
        notifications.value = updatedNotifications;
        _applyFilter();

        Get.snackbar(
          'Success',
          '$count notification(s) marked as read',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green[800],
        );
        // Refresh dashboard unread count
        try {
          Get.find<DoctorDashboardController>().refreshUnreadCount();
        } catch (_) {
          // DashboardController not initialized yet
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to mark all as read',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
      );
    } finally {
      isMarkingAll.value = false;
    }
  }

  void onNotificationTap(NotificationModel notification) {
    if (!notification.isRead) {
      markAsRead(notification.id);
    }

    // Navigate based on notification type and data
    // This will be implemented when we have the navigation routes
    Get.snackbar(
      'Info',
      'Navigating to ${notification.type.displayName}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary.withOpacity(0.1),
      colorText: AppColors.primary,
    );
  }
}
