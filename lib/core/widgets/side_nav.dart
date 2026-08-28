import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';
import 'package:get/get.dart';

class SideNav extends StatelessWidget {
  final String currentRoute;

  const SideNav({super.key, this.currentRoute = '/dashboard'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 80),
          _buildNavItem(
            icon: 'dashboard',
            label: 'Home',
            isActive: currentRoute == AppRoutes.dashboard,
            onTap: () => _navigate(context, AppRoutes.dashboard),
          ),
          _buildNavItem(
            icon: 'groups',
            label: 'Patients',
            isActive: currentRoute == AppRoutes.patients,
            onTap: () => _navigate(context, AppRoutes.patients),
          ),
          _buildNavItem(
            icon: 'calendar_today',
            label: 'Schedule',
            isActive: currentRoute == AppRoutes.appointments,
            onTap: () => _navigate(context, AppRoutes.appointments),
          ),
          _buildNavItem(
            icon: 'emergency',
            label: 'Emergency',
            isActive: currentRoute == AppRoutes.sos,
            onTap: () => _navigate(context, AppRoutes.sos),
          ),
          const Spacer(),
          _buildNavItem(
            icon: 'settings',
            label: 'Settings',
            isActive: currentRoute == AppRoutes.settings,
            onTap: () => _navigate(context, AppRoutes.settings),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.secondaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            MaterialSymbolIcon(
              icon,
              size: 24,
              color: isActive
                  ? AppColors.onSecondaryContainer
                  : AppColors.onSurfaceVariant,
              fill: isActive,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? AppColors.onSecondaryContainer
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    if (route != currentRoute) {
      Get.offNamed(route);
    }
  }
}
