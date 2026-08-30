import 'package:flutter/material.dart';
import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';

/// A full-width, 52px-tall stat bar — same footprint as the primary
/// login button (`SizedBox(width: double.infinity, height: 52, ...)`).
///
/// Use this for a single "hero" metric you want to visually lead with
/// (e.g. Total Patients) instead of burying it in the metric grid.
class DashboardHeroStat extends StatelessWidget {
  final String iconName;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const DashboardHeroStat({
    super.key,
    required this.iconName,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: MaterialSymbolIcon(
                      iconName,
                      size: 18,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  value,
                  style: AppTheme.headlineSmall.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.onPrimary.withOpacity(0.85),
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
