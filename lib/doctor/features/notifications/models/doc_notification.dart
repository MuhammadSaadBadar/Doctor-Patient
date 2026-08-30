// lib/features/notifications/models/notification.dart

import 'package:doctor/core/constants/color_constants.dart';
import 'package:flutter/material.dart';

/// Notification type enum matching API spec
enum NotificationType {
  appointment,
  medicine,
  diet,
  doctorMessage,
  weeklyUpdate,
  emergency,
  broadcast,
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.appointment:
        return 'Appointment';
      case NotificationType.medicine:
        return 'Medicine';
      case NotificationType.diet:
        return 'Diet';
      case NotificationType.doctorMessage:
        return 'Doctor Message';
      case NotificationType.weeklyUpdate:
        return 'Weekly Update';
      case NotificationType.emergency:
        return 'Emergency';
      case NotificationType.broadcast:
        return 'Broadcast';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.appointment:
        return Icons.calendar_today_rounded;
      case NotificationType.medicine:
        return Icons.medication_rounded;
      case NotificationType.diet:
        return Icons.restaurant_menu_rounded;
      case NotificationType.doctorMessage:
        return Icons.chat_rounded;
      case NotificationType.weeklyUpdate:
        return Icons.update_rounded;
      case NotificationType.emergency:
        return Icons.sos_rounded;
      case NotificationType.broadcast:
        return Icons.campaign_rounded;
    }
  }

  Color get iconColor {
    switch (this) {
      case NotificationType.appointment:
        return AppColors.primary;
      case NotificationType.medicine:
        return AppColors.secondary;
      case NotificationType.diet:
        return AppColors.tertiaryContainer;
      case NotificationType.doctorMessage:
        return AppColors.primary;
      case NotificationType.weeklyUpdate:
        return AppColors.onSurfaceVariant;
      case NotificationType.emergency:
        return AppColors.error;
      case NotificationType.broadcast:
        return AppColors.secondary;
    }
  }

  Color get iconBackgroundColor {
    return iconColor.withOpacity(0.12);
  }
}

/// Notification model
class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final bool channelPushSent;
  final bool channelWhatsappSent;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.isRead,
    required this.channelPushSent,
    required this.channelWhatsappSent,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      type: _parseNotificationType(json['notification_type'] ?? ''),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['is_read'] as bool? ?? false,
      channelPushSent: json['channel_push_sent'] as bool? ?? false,
      channelWhatsappSent: json['channel_whatsapp_sent'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  static NotificationType _parseNotificationType(String value) {
    switch (value) {
      case 'appointment':
        return NotificationType.appointment;
      case 'medicine':
        return NotificationType.medicine;
      case 'diet':
        return NotificationType.diet;
      case 'doctor_message':
        return NotificationType.doctorMessage;
      case 'weekly_update':
        return NotificationType.weeklyUpdate;
      case 'emergency':
        return NotificationType.emergency;
      case 'broadcast':
        return NotificationType.broadcast;
      default:
        return NotificationType.broadcast;
    }
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays > 7) {
      return '${diff.inDays ~/ 7}w ago';
    } else if (diff.inDays > 0) {
      return diff.inDays == 1 ? 'Yesterday' : '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return diff.inHours == 1 ? '1 hour ago' : '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return diff.inMinutes == 1 ? '1 min ago' : '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Check if notification has deep link action
  bool get hasAction {
    return data != null && data!.isNotEmpty;
  }

  /// Get action label based on type
  String get actionLabel {
    switch (type) {
      case NotificationType.appointment:
        return 'View Appointment';
      case NotificationType.medicine:
        return 'View Reminder';
      case NotificationType.diet:
        return 'View Diet Plan';
      case NotificationType.doctorMessage:
        return 'Open Chat';
      case NotificationType.emergency:
        return 'View SOS';
      case NotificationType.weeklyUpdate:
        return 'View Update';
      case NotificationType.broadcast:
        return 'View Details';
    }
  }
}

/// Paginated notification list result
class NotificationListResult {
  final List<NotificationModel> notifications;
  final int totalCount;
  final bool hasNext;

  NotificationListResult({
    required this.notifications,
    required this.totalCount,
    required this.hasNext,
  });
}
