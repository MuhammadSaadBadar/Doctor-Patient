import 'package:flutter/material.dart';
import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';

class SettingsTile extends StatelessWidget {
  final String icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? textColor;
  final Color? iconColor;
  final bool isFirst;
  final bool isLast;
  final bool isOnly;
  final Widget? trailing;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.textColor,
    this.iconColor,
    this.isFirst = false,
    this.isLast = false,
    this.isOnly = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.only(
      topLeft: isFirst || isOnly ? const Radius.circular(12) : Radius.zero,
      topRight: isFirst || isOnly ? const Radius.circular(12) : Radius.zero,
      bottomLeft: isLast || isOnly ? const Radius.circular(12) : Radius.zero,
      bottomRight: isLast || isOnly ? const Radius.circular(12) : Radius.zero,
    );

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        hoverColor: AppColors.surfaceContainerLow.withOpacity(0.5),
        highlightColor: AppColors.surfaceContainerLow.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              MaterialSymbolIcon(
                icon,
                size: 24,
                color: iconColor ?? AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodyMedium.copyWith(
                        color: textColor ?? AppColors.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
              if (onTap != null && trailing == null)
                MaterialSymbolIcon(
                  'chevron_right',
                  size: 24,
                  color: AppColors.outline,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
