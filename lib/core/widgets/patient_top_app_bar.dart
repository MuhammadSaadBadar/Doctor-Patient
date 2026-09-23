import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PatientTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final Color? titleColor;
  final VoidCallback? onNotificationTap;
  final List<Widget>? trailingActions;
  final double height;
  final Widget Function(BuildContext)? titleBuilder;
  final Widget? customTitle;
  final List<Widget>? customActions;
  final Widget? leading;

  const PatientTopAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.titleColor,
    this.onNotificationTap,
    this.trailingActions,
    this.height = 56,
    this.titleBuilder,
    this.customTitle,
    this.customActions,
    this.leading,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final resolvedShowBack = showBackButton && canPop;

    // Light theme: Primary background, White foreground
    // Dark theme: White background, Background foreground
    final bgColor = isDark ? Colors.white : cs.primary;
    final iconColor = isDark ? cs.background : cs.onPrimary;
    final titleColorResolved = titleColor ?? (isDark ? cs.background : cs.onPrimary);
    final backBgColor = isDark
        ? Colors.transparent
        : cs.onPrimary.withValues(alpha: 0.12);

    return SafeArea(
      top: true,
      bottom: false,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          border: isDark
              ? Border(
                  bottom: BorderSide(
                    color: cs.outlineVariant.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                )
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Leading widget (back button or custom)
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 12),
            ] else if (resolvedShowBack) ...[
              Material(
                color: backBgColor,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () => Get.back(),
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: iconColor,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ] else
              const SizedBox(width: 4),

            // Title
            Expanded(child: _buildTitle(context, titleColorResolved)),

            // Custom actions (highest priority)
            if (customActions != null) ...customActions!,

            // Trailing actions
            if (trailingActions != null) ...trailingActions!,

            // Notification bell
            if (onNotificationTap != null) ...[
              const SizedBox(width: 4),
              _NotificationBell(
                onTap: onNotificationTap!,
                iconColor: iconColor,
                badgeColor: cs.error,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, Color titleColorResolved) {
    if (customTitle != null) return customTitle!;
    if (titleBuilder != null) return titleBuilder!(context);
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'PlayfairDisplay',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: titleColorResolved,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final VoidCallback onTap;
  final Color iconColor;
  final Color badgeColor;

  const _NotificationBell({
    required this.onTap,
    required this.iconColor,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_rounded, color: iconColor, size: 22),
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.onError,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
