// lib/patient/features/water_intake/screens/water_intake_screen.dart

import 'package:doctor/patient/features/water_intake/controllers/water_intake_controller.dart';
import 'package:doctor/patient/features/water_intake/widgets/glass_counter.dart';
import 'package:doctor/patient/features/water_intake/widgets/hydration_tip_card.dart';
import 'package:doctor/patient/features/water_intake/widgets/weekly_history_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WaterIntakeScreen extends GetView<WaterIntakeController> {
  const WaterIntakeScreen({super.key});

  static const int glassSizeMl = 250;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final targetGlasses = (controller.targetMl.value / glassSizeMl).round();

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Mama Health',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: colorScheme.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.history_rounded,
              color: colorScheme.onSurface,
            ),
            onPressed: controller.navigateToHistory,
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_rounded,
              color: colorScheme.onSurface,
            ),
            onPressed: () => Get.toNamed('/notifications'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.todayIntake.value == null) {
          return _buildLoadingState(context);
        }

        if (controller.hasError.value) {
          return _buildErrorState(context);
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              16, 8, 16, MediaQuery.of(context).padding.bottom + 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context, targetGlasses),

                // Bento Grid
                _buildBentoGrid(context),

                // History Button
                const SizedBox(height: 16),
                _buildHistoryButton(context),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context, int targetGlasses) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hydration Tracker',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Stay hydrated for you and your baby. Goal: $targetGlasses glasses daily.',
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 768;

        return isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 8, child: _buildMainCard(context)),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        _buildWeeklyHistory(context),
                        const SizedBox(height: 16),
                        _buildHydrationTip(context),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildMainCard(context),
                  const SizedBox(height: 16),
                  _buildWeeklyHistory(context),
                  const SizedBox(height: 16),
                  _buildHydrationTip(context),
                ],
              );
      },
    );
  }

  Widget _buildMainCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final targetGlasses = (controller.targetMl.value / glassSizeMl).round();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.04),
            blurRadius: 32,
          ),
        ],
      ),
      child: Column(
        children: [
          // Glass Counter
          GlassCounter(
            glasses: controller.glasses,
            targetGlasses: targetGlasses,
            onAdd: () => controller.addWater(glassSizeMl),
            onRemove: () {
              if (controller.glasses > 0) {
                Get.snackbar(
                  'Info',
                  'Remove functionality coming soon',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
          ),
          const SizedBox(height: 16),

          // Progress info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoChip(
                context,
                icon: Icons.water_drop_rounded,
                label: '${controller.glasses} / $targetGlasses',
                color: colorScheme.tertiary,
              ),
              const SizedBox(width: 12),
              _buildInfoChip(
                context,
                icon: Icons.arrow_circle_right_rounded,
                label: '${controller.remainingMl} ml left',
                color: colorScheme.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyHistory(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.04),
            blurRadius: 32,
          ),
        ],
      ),
      child: WeeklyHistoryChart(
        weeklyIntake: controller.weeklyIntake.value,
        todayGlasses: controller.glasses,
      ),
    );
  }

  Widget _buildHydrationTip(BuildContext context) {
    final tips = [
      'Drinking water before meals can help support healthy digestion during your second trimester.',
      'Try adding lemon or cucumber to your water for natural flavor and extra nutrients.',
      'Carry a reusable water bottle to track your intake throughout the day.',
      'Set reminders on your phone to drink water every hour.',
      'Herbal teas and water-rich fruits count toward your daily hydration goal.',
    ];

    final randomTip = tips[DateTime.now().day % tips.length];

    return HydrationTipCard(tip: randomTip);
  }

  Widget _buildHistoryButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: controller.navigateToHistory,
        icon: const Icon(Icons.history_rounded, size: 20),
        label: const Text(
          'View Full History',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home_rounded,
                label: 'Home',
                onTap: controller.navigateToHome,
                isActive: false,
              ),
              _buildNavItem(
                context,
                icon: Icons.event_rounded,
                label: 'Booking',
                onTap: controller.navigateToBooking,
                isActive: false,
              ),
              _buildNavItem(
                context,
                icon: Icons.local_drink_rounded,
                label: 'Hydrate',
                onTap: () {},
                isActive: true,
              ),
              _buildNavItem(
                context,
                icon: Icons.description_rounded,
                label: 'Reports',
                onTap: controller.navigateToReports,
                isActive: false,
              ),
              _buildNavItem(
                context,
                icon: Icons.person_rounded,
                label: 'Profile',
                onTap: controller.navigateToProfile,
                isActive: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.secondaryContainer.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? colorScheme.secondary : colorScheme.outline,
              size: 24,
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? colorScheme.secondary : colorScheme.outline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading...',
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}