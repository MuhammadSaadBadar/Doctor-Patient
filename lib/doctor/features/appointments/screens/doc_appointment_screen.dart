import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/core/widgets/bottom_nav_bar.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';
import 'package:doctor/core/widgets/doc_top_app_bar.dart';
import 'package:doctor/doctor/features/appointments/models/doc_appointment_schedule.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/doctor/features/appointments/widgets/doc_appointment_card.dart';
import 'package:doctor/doctor/features/appointments/widgets/doc_appointment_list_item.dart';
import 'package:doctor/doctor/features/appointments/controllers/doc_appointment_controller.dart';

class DoctorAppointmentScreen extends GetView<DoctorAppointmentController> {
  const DoctorAppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: const TopAppNavBar.gradient(
        title: 'Appointments',
        height: 64,
        showBackButton: false,
      ),
      body: Obx(() {
        if (controller.isLoadingProp) {
          return _buildLoadingState();
        }

        if (controller.hasErrorProp) {
          return _buildErrorState(context);
        }

        return RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surfaceContainerLowest,
          onRefresh: () async => controller.refreshAppointments(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              isDesktop ? 32 : 16,
              16,
              isDesktop ? 32 : 16,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildTabNavigation(),
                const SizedBox(height: 20),
                _buildContentView(context),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  // ── Header banner ───────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Schedule',
                  style: AppTheme.headlineLargeMobile.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your upcoming and past appointments.',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppColors.onPrimary.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.onPrimary.withOpacity(0.10),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.onPrimary.withOpacity(0.20),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              color: AppColors.onPrimary.withOpacity(0.80),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab navigation ──────────────────────────────────────────────────────────

  // Widget _buildTabNavigation() {
  //   return Container(
  //     padding: const EdgeInsets.all(4),
  //     decoration: BoxDecoration(
  //       color: AppColors.primary,
  //       borderRadius: BorderRadius.circular(14),
  //     ),
  //     child: Obx(
  //       () => SingleChildScrollView(
  //         scrollDirection: Axis.horizontal,
  //         child: Row(
  //           children: [
  //             _buildTabButton(
  //               label: 'Upcoming',
  //               icon: Icons.upcoming_rounded,
  //               isActive:
  //                   controller.currentTab.value == AppointmentTab.upcoming,
  //               onTap: () => controller.switchTab(AppointmentTab.upcoming),
  //             ),
  //             _buildTabButton(
  //               label: 'Completed',
  //               icon: Icons.check_circle_outline_rounded,
  //               isActive:
  //                   controller.currentTab.value == AppointmentTab.completed,
  //               onTap: () => controller.switchTab(AppointmentTab.completed),
  //             ),
  //             _buildTabButton(
  //               label: 'Paid',
  //               icon: Icons.payments_rounded,
  //               isActive: controller.currentTab.value == AppointmentTab.paid,
  //               onTap: () => controller.switchTab(AppointmentTab.paid),
  //             ),
  //             _buildTabButton(
  //               label: 'Unpaid',
  //               icon: Icons.pending_actions_rounded,
  //               isActive: controller.currentTab.value == AppointmentTab.unpaid,
  //               onTap: () => controller.switchTab(AppointmentTab.unpaid),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _buildTabNavigation() {
    final tabs = <({AppointmentTab tab, String label})>[
      (tab: AppointmentTab.upcoming, label: 'Upcoming'),
      (tab: AppointmentTab.completed, label: 'Completed'),
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant.withOpacity(0.3)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((tabData) {
            return Obx(() {
              final selected = controller.currentTab.value == tabData.tab;
              return GestureDetector(
                onTap: () => controller.switchTab(tabData.tab),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 4,
                  ),
                  margin: const EdgeInsetsDirectional.only(end: 32),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: selected
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    tabData.label,
                    style: AppTheme.labelLarge.copyWith(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      letterSpacing: 0.05,
                      color: selected
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            });
          }).toList(),
        ),
      ),
    );
  }

  // ── Loading state ───────────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.outlineSubtle,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading appointments…',
            style: AppTheme.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ── Error state ─────────────────────────────────────────────────────────────

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Something went wrong',
              style: AppTheme.titleLarge.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessageProp,
              style: AppTheme.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: controller.refreshAppointments,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Content view ────────────────────────────────────────────────────────────

  Widget _buildContentView(BuildContext context) {
    final appointments = controller.filteredAppointments;

    if (appointments.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.45,
        child: _buildEmptyState(
          icon: _getEmptyIcon(),
          title: _getEmptyTitle(),
          message: _getEmptyMessage(),
        ),
      );
    }

    if (controller.currentTab.value == AppointmentTab.upcoming) {
      return _buildUpcomingView(context, appointments);
    }

    return _buildListView(context, appointments);
  }

  String _getEmptyIcon() {
    switch (controller.currentTab.value) {
      case AppointmentTab.upcoming:
        return 'event_available';
      case AppointmentTab.completed:
        return 'history';
    }
  }

  String _getEmptyTitle() {
    switch (controller.currentTab.value) {
      case AppointmentTab.upcoming:
        return 'No Confirmed Paid Appointments';
      case AppointmentTab.completed:
        return 'No Completed Appointments';
    }
  }

  String _getEmptyMessage() {
    switch (controller.currentTab.value) {
      case AppointmentTab.upcoming:
        return 'Appointments appear here once payment is confirmed.';
      case AppointmentTab.completed:
        return 'You have no completed appointments yet.';
    }
  }

  Widget _buildUpcomingView(
    BuildContext context,
    List<AppointmentSchedule> appointments,
  ) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;
    final crossAxisCount = isDesktop ? 3 : (width >= 768 ? 2 : 1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isDesktop ? 24 : 14,
        mainAxisSpacing: isDesktop ? 24 : 14,
        childAspectRatio: isDesktop ? 1.3 : 1.25,
      ),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        return AppointmentCard(
          appointment: appointments[index],
          onReschedule: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Reschedule functionality coming soon'),
              ),
            );
          },
          onViewRecords: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('View records functionality coming soon'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildListView(
    BuildContext context,
    List<AppointmentSchedule> appointments,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: appointments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return AppointmentListItem(
          appointment: appointments[index],
          onViewNotes: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('View notes functionality coming soon'),
              ),
            );
          },
        );
      },
    );
  }

  // ── Empty state ─────────────────────────────────────────────────────────────

  Widget _buildEmptyState({
    required String icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: MaterialSymbolIcon(
                icon,
                size: 38,
                color: AppColors.primaryMuted,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: AppTheme.headlineSmall.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: AppTheme.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
