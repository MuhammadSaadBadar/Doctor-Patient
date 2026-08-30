import 'package:doctor/core/constants/color_constants.dart';
import 'package:flutter/material.dart';

class DashboardMetric {
  final String id;
  final String iconName;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final String value;
  final String? badge;
  final Color badgeColor;
  final Color badgeTextColor;
  final bool showOnMobile;

  DashboardMetric({
    required this.id,
    required this.iconName,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    required this.value,
    this.badge,
    this.badgeColor = Colors.transparent,
    this.badgeTextColor = AppColors.onSurfaceVariant,
    this.showOnMobile = true,
  });
}
