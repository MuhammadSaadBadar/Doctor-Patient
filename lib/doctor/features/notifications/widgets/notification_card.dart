// lib/features/notifications/widgets/notification_card.dart

import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/doctor/features/notifications/models/doc_notification.dart';
import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback? onActionTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: notification.isRead
            ? AppColors.surface
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(
            // <-- WRAP WITH IntrinsicHeight
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.outlineVariant.withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Unread indicator (left border)
                  if (!notification.isRead)
                    Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: const BorderRadiusDirectional.only(
                          topStart: Radius.circular(12),
                          bottomStart: Radius.circular(12),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: notification.isRead ? 16 : 12,
                        end: 16,
                        top: 16,
                        bottom: 16,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: notification.type.iconBackgroundColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              notification.type.icon,
                              size: 20,
                              color: notification.type.iconColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title and time
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notification.title,
                                        style: AppTheme.headlineSmall.copyWith(
                                          fontWeight: notification.isRead
                                              ? FontWeight.w600
                                              : FontWeight.w700,
                                          color: notification.isRead
                                              ? AppColors.onSurface
                                              : AppColors.primary,
                                          fontSize: isMobile ? 14 : 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      notification.timeAgo,
                                      style: AppTheme.bodySmall.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                        fontSize: isMobile ? 10 : 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                // Body
                                Text(
                                  notification.body,
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: isMobile ? 13 : 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // Action button
                                if (notification.hasAction) ...[
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: onActionTap ?? onTap,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          notification.actionLabel,
                                          style: AppTheme.labelMedium.copyWith(
                                            color: AppColors.secondary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 14,
                                          color: AppColors.secondary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
