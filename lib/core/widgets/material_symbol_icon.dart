import 'package:doctor/core/constants/color_constants.dart';
import 'package:flutter/material.dart';

class MaterialSymbolIcon extends StatelessWidget {
  final String iconName;
  final double size;
  final Color? color;
  final bool fill;

  const MaterialSymbolIcon(
    this.iconName, {
    super.key,
    this.size = 24,
    this.color,
    this.fill = false,
  });

  @override
  Widget build(BuildContext context) {
    // Map Material Symbol names to Material Icons
    return Icon(
      _getIconData(iconName),
      size: size,
      color: color ?? Theme.of(context).iconTheme.color,
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'mail':
        return Icons.mail_outline;
      case 'lock':
        return Icons.lock_outline;
      case 'visibility':
        return Icons.visibility;
      case 'visibility_off':
        return Icons.visibility_off;
      case 'help':
        return Icons.help_outline;
      case 'menu':
        return Icons.menu;
      case 'notifications':
        return Icons.notifications_outlined;
      case 'dashboard':
        return Icons.dashboard;
      case 'groups':
        return Icons.people;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'settings':
        return Icons.settings;
      case 'search':
        return Icons.search;
      case 'filter_list':
        return Icons.filter_list;
      case 'person':
        return Icons.person;
      case 'group':
        return Icons.group;
      case 'event':
        return Icons.event;
      case 'warning':
        return Icons.warning;
      case 'article':
        return Icons.article;
      case 'videocam':
        return Icons.videocam;
      case 'add':
        return Icons.add;
      case 'more_vert':
        return Icons.more_vert;
      case 'arrow_back':
        return Icons.arrow_back;
      case 'arrow_forward':
        return Icons.arrow_forward;
      case 'check_circle':
        return Icons.check_circle;
      case 'radio_button_unchecked':
        return Icons.radio_button_unchecked;
      case 'lock_reset':
        return Icons.lock_reset;
      case 'restaurant_menu':
        return Icons.restaurant_menu;
      case 'inventory_2':
        return Icons.inventory_2;
      case 'sort':
        return Icons.sort;
      case 'chevron_right':
        return Icons.chevron_right;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'schedule':
        return Icons.schedule;
      case 'enhanced_encryption':
        return Icons.enhanced_encryption;
      case 'event_busy':
        return Icons.event_busy;
      case 'calendar_month':
        return Icons.calendar_month;
      case 'save':
        return Icons.save;
      case 'show_chart':
        return Icons.show_chart;
      case 'bar_chart':
        return Icons.bar_chart;
      case 'water_drop':
        return Icons.water_drop;
      case 'history':
        return Icons.history;
      case 'error_outline':
        return Icons.error_outline;
      case 'search':
        return Icons.search;
      case 'filter_alt_off':
        return Icons.filter_alt_off;
      default:
        return Icons.circle;
    }
  }
}
