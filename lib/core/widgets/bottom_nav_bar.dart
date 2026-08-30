import 'package:doctor/core/controllers/navigation_controller.dart';
import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavItem {
  final String iconName;
  final String activeIconName;
  final String label;
  final String route;

  const BottomNavItem({
    required this.iconName,
    required this.label,
    required this.route,
    String? activeIconName,
  }) : activeIconName = activeIconName ?? iconName;
}

class BottomNavBar extends StatelessWidget {
  final List<BottomNavItem> items;

  const BottomNavBar({super.key, this.items = _defaultItems});

  static const _defaultItems = [
    BottomNavItem(
      iconName: 'dashboard',
      activeIconName: 'dashboard',
      label: 'Dashboard',
      route: AppRoutes.docdashboard,
    ),
    BottomNavItem(
      iconName: 'calendar_today',
      activeIconName: 'calendar_today',
      label: 'Appointments',
      route: AppRoutes.docappointments,
    ),
    BottomNavItem(
      iconName: 'groups',
      activeIconName: 'groups',
      label: 'Patients',
      route: AppRoutes.docpatients,
    ),
    BottomNavItem(
      iconName: 'emergency',
      activeIconName: 'emergency',
      label: 'Emergency',
      route: AppRoutes.docsos,
    ),
    BottomNavItem(
      iconName: 'settings',
      activeIconName: 'settings',
      label: 'Settings',
      route: AppRoutes.docsettings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    if (isDesktop) return const SizedBox.shrink();

    final navBarBg =
        Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.surfaceContainerLowest;
    final outlineColor = Theme.of(context).colorScheme.outlineVariant;

    // Use Get.find with try-catch for robust controller access
    NavigationController? controller;
    try {
      controller = Get.find<NavigationController>();
    } catch (_) {
      controller = null;
    }

    // If controller is not available, return a basic nav bar without reactive state
    if (controller == null) {
      return Container(
        decoration: BoxDecoration(
          color: navBarBg,
          border: Border(top: BorderSide(color: outlineColor, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              children: items.map((item) {
                return Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Get.toNamed(item.route),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MaterialSymbolIcon(
                              item.iconName,
                              size: 22,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.label,
                              style: AppTheme.labelMedium.copyWith(
                                fontSize: 11,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );
    }

    final navController = controller!;

    return Container(
      decoration: BoxDecoration(
        color: navBarBg,
        border: Border(top: BorderSide(color: outlineColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Obx(
            () => Row(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final active = navController.currentIndex.value == index;
                return Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        if (!active) navController.onTabTap(index);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Active indicator dot
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: active ? 20 : 0,
                              height: active ? 3 : 0,
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            // Icon pill
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: active
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: MaterialSymbolIcon(
                                active ? item.activeIconName : item.iconName,
                                size: 22,
                                color: active
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                fill: active,
                              ),
                            ),
                            const SizedBox(height: 3),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: AppTheme.labelMedium.copyWith(
                                fontSize: 11,
                                fontWeight: active
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: active
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                              ),
                              child: Text(item.label),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
