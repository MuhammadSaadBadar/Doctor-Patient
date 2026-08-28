import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';
import 'package:doctor/core/routes/app_routes.dart';

/// Shared top bar used across every screen in the app.
///
/// Usage:
/// ```dart
/// Scaffold(
///   body: Column(
///     children: [
///       const TopAppNavBar(title: 'Dashboard'),
///       Expanded(child: ...),
///     ],
///   ),
/// )
/// ```
///
/// - Pass [title] explicitly per screen (recommended) — if omitted, it
///   falls back to a title derived from the current route name.
/// - [showBackButton] defaults to auto-detecting whether the current route
///   can be popped; pass `false` to force-hide it (e.g. on tab roots).
/// - [onNotificationTap] / [notificationCount] wire up the bell icon; the
///   icon is hidden entirely if [onNotificationTap] is null.
/// - [onProfileTap] wires up the trailing avatar; defaults to navigating to
///   '/settings' — change that route to match your app if different.
/// - [useGradient] enables a theme-aware gradient header (dark blue in light mode, light surface in dark mode)
/// - [subtitle] for a secondary line under the title.
/// - [leadingIcon] for a leading icon in a circular container.
/// - [trailingActions] for custom trailing widgets.
/// - [centerTitle] to center the title (e.g. auth screens).
/// - [height] for custom height; defaults to 64, or auto for gradient.
class TopAppNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool? showBackButton;
  final VoidCallback? onNotificationTap;
  final int notificationCount;
  final VoidCallback? onProfileTap;
  final String? profileInitials;
  final List<Widget>? extraActions;

  // Enhanced customization
  final bool useGradient;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget? leadingIcon;
  final String? leadingIconSemanticLabel;
  final List<Widget>? trailingActions;
  final bool centerTitle;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? titleColor;
  final Color? iconColor;
  final Color? backButtonBackgroundColor;

  const TopAppNavBar({
    super.key,
    this.title,
    this.showBackButton,
    this.onNotificationTap,
    this.notificationCount = 0,
    this.onProfileTap,
    this.profileInitials,
    this.extraActions,
    this.useGradient = false,
    this.subtitle,
    this.subtitleWidget,
    this.leadingIcon,
    this.leadingIconSemanticLabel,
    this.trailingActions,
    this.centerTitle = false,
    this.height,
    this.padding,
    this.titleColor,
    this.iconColor,
    this.backButtonBackgroundColor,
  });

  /// Creates a gradient header variant (theme-aware: dark blue in light mode, light surface in dark mode).
  const TopAppNavBar.gradient({
    super.key,
    required String this.title,
    this.subtitle,
    this.subtitleWidget,
    this.showBackButton,
    this.leadingIcon,
    this.leadingIconSemanticLabel,
    this.trailingActions,
    this.onNotificationTap,
    this.notificationCount = 0,
    this.onProfileTap,
    this.profileInitials,
    this.centerTitle = false,
    this.height,
    this.padding,
    this.titleColor,
    this.iconColor,
    this.backButtonBackgroundColor,
    this.extraActions,
  }) : useGradient = true;

  @override
  Size get preferredSize => Size.fromHeight(
    height ?? (useGradient ? 100 : 64),
  );

  String _fallbackTitleFromRoute() {
    final route = Get.currentRoute;
    if (route.isEmpty || route == '/') return 'Home';
    final segment =
        route.split('/').where((s) => s.isNotEmpty).lastOrNull ?? route;
    final words = segment.replaceAll('-', ' ').split(' ');
    return words
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final resolvedShowBack = showBackButton ?? canPop;
    final resolvedTitle = title ?? _fallbackTitleFromRoute();
    final isGradient = useGradient;

    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final primaryContainer = Theme.of(context).colorScheme.primaryContainer;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use theme-aware gradient when useGradient is true
    final gradient = isGradient ? AppTheme.getNavigationGradient(context) : null;

    final resolvedTitleColor = titleColor ??
        (isGradient ? onPrimary : primary);
    final resolvedIconColor = iconColor ??
        (isGradient ? onPrimary : primary);
    final resolvedBackBg = backButtonBackgroundColor ??
        (isGradient
            ? Colors.transparent
            : primaryContainer.withOpacity(0.1));
    final resolvedBackIconColor = iconColor ??
        (isGradient ? onPrimary : primary);
    final resolvedHeight = height ?? (isGradient ? 100 : 64);
    final resolvedPadding = padding ?? const EdgeInsets.symmetric(horizontal: 12);
    final surfaceColor = isGradient ? null : Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surface;
    final borderColor = isGradient ? null : Theme.of(context).dividerTheme.color?.withOpacity(0.5) ?? Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5);
    final shadowColor = isGradient ? null : Colors.black.withOpacity(0.04);

    // Use fallback values for non-gradient mode
    final effectiveSurfaceColor = surfaceColor ?? Theme.of(context).colorScheme.surface;
    final effectiveBorderColor = borderColor ?? Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5);
    final effectiveShadowColor = shadowColor ?? Colors.black.withOpacity(0.04);

    return SafeArea(
      top: true,
      bottom: false,
      child: Container(
        height: resolvedHeight,
        padding: resolvedPadding,
        decoration: BoxDecoration(
          gradient: gradient,
          color: effectiveSurfaceColor,
          border: isGradient
              ? null
              : Border(
                  bottom: BorderSide(
                    color: effectiveBorderColor,
                    width: 1,
                  ),
                ),
          boxShadow: isGradient
              ? null
              : [
                  BoxShadow(
                    color: effectiveShadowColor,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (resolvedShowBack) ...[
              Material(
                color: resolvedBackBg,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () => Get.back(),
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: resolvedBackIconColor,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ] else
              const SizedBox(width: 4),

            if (leadingIcon != null) ...[
              leadingIcon!,
              const SizedBox(width: 10),
            ],

            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                children: [
                  Text(
                    resolvedTitle,
                    style: isGradient
                        ? AppTheme.headlineSmall.copyWith(
                            color: resolvedTitleColor,
                            fontWeight: FontWeight.w700,
                          )
                        : TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: resolvedTitleColor,
                          ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                  ),
                  if (subtitleWidget != null) ...[
                    const SizedBox(height: 2),
                    subtitleWidget!,
                  ] else if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTheme.bodySmall.copyWith(
                        color: resolvedTitleColor.withOpacity(0.65),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                    ),
                  ],
                ],
              ),
            ),

            if (extraActions != null) ...extraActions!,

            if (trailingActions != null) ...trailingActions!,

            if (onNotificationTap != null)
              _IconWithBadge(
                onTap: onNotificationTap!,
                count: notificationCount,
                iconColor: resolvedIconColor,
                badgeColor: Theme.of(context).colorScheme.error,
              ),

            if (onProfileTap != null) ...[
              const SizedBox(width: 4),
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onProfileTap,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        profileInitials ?? '?',
                        style: AppTheme.labelMedium.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IconWithBadge extends StatelessWidget {
  final VoidCallback onTap;
  final int count;
  final Color iconColor;
  final Color badgeColor;

  const _IconWithBadge({
    required this.onTap,
    required this.count,
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
              MaterialSymbolIcon(
                'notifications',
                size: 22,
                color: iconColor,
              ),
              if (count > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1,
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

extension _LastOrNull<T> on List<T> {
  T? get lastOrNull => isEmpty ? null : last;
}

/// Alias for backward compatibility and shorter usage
typedef TopAppBar = TopAppNavBar;
