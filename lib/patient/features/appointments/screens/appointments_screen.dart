// lib/patient/features/appointments/screens/appointments_screen.dart

import 'package:doctor/core/localization/translation_keys.dart';
import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:doctor/patient/features/appointments/controllers/appointment_controller.dart';
import 'package:doctor/patient/features/appointments/widgets/appointment_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppointmentsScreen extends GetView<AppointmentController> {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: PatientTopAppBar(
        title: TranslationKeys.appointmentsTitle.tr,
        // trailingActions: [
        //   Container(
        //     margin: const EdgeInsetsDirectional.only(end: 8),
        //     child: _buildBookButton(context),
        //   ),
        // ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.allAppointments.isEmpty) {
          return _buildLoadingState(context);
        }

        if (controller.hasError.value && controller.allAppointments.isEmpty) {
          return _buildErrorState(context);
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: cs.primary,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification) {
                final metrics = notification.metrics;
                if (metrics.pixels >= metrics.maxScrollExtent - 200) {
                  controller.loadMore();
                }
              }
              return false;
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize:
                    MainAxisSize.min, // ✅ Prevents unbounded height issues
                children: [
                  _buildWelcomeSection(context),
                  const SizedBox(height: 16),
                  _buildFilterChips(context),
                  const SizedBox(height: 16),
                  _buildAppointmentList(context),
                ],
              ),
            ),
          ),
        );
      }),
      // floatingActionButton: _buildFAB(context),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ==================== WELCOME SECTION ====================

  Widget _buildWelcomeSection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // ✅ Added
      children: [
        Text(
          TranslationKeys.appointmentsYourAppointments.tr,
          style: TextStyle(
            fontSize: textScale.scale(22).clamp(18.0, 26.0),
            fontWeight: FontWeight.w700,
            color: cs.primary,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          TranslationKeys.appointmentsSubtitle.tr,
          style: TextStyle(
            fontSize: textScale.scale(13).clamp(11.0, 14.0),
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ==================== BOOK BUTTON ====================

  // Widget _buildBookButton(BuildContext context) {
  //   final cs = Theme.of(context).colorScheme;

  //   return GestureDetector(
  //     onTap: controller.navigateToBookAppointment,
  //     child: Container(
  //       height: 34,
  //       padding: const EdgeInsets.symmetric(horizontal: 12),
  //       decoration: BoxDecoration(
  //         color: cs.onPrimary.withValues(alpha: 0.15),
  //         borderRadius: BorderRadius.circular(30),
  //         border: Border.all(color: cs.onPrimary.withValues(alpha: 0.3)),
  //       ),
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Icon(Icons.add_rounded, size: 16, color: cs.onPrimary),
  //           const SizedBox(width: 4),
  //           Text(
  //             TranslationKeys.appointmentsBookNew.tr,
  //             style: TextStyle(
  //               fontSize: 12,
  //               fontWeight: FontWeight.w600,
  //               color: cs.onPrimary,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // ==================== FILTER CHIPS ====================

  Widget _buildFilterChips(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);
    final filters = AppointmentFilter.values;

    // ✅ Fixed: Added SizedBox with explicit height for horizontal ListView
    return SizedBox(
      height: 44, // Fixed height for horizontal ListView
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = controller.selectedFilter.value == filter;
          final count = controller.getFilterCount(filter);

          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: GestureDetector(
              onTap: () => controller.setFilter(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? cs.primary : cs.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected ? cs.primary : cs.outlineVariant,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: cs.primary.withValues(alpha: 0.28),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getFilterIcon(filter),
                      size: 13,
                      color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      controller.getFilterLabel(filter),
                      style: TextStyle(
                        fontSize: textScale.scale(11).clamp(9.0, 12.0),
                        fontWeight: FontWeight.w600,
                        color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cs.onPrimary.withValues(alpha: 0.22)
                              : cs.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? cs.onPrimary : cs.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==================== APPOINTMENT LIST ====================

  Widget _buildAppointmentList(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final appointments = controller.filteredAppointments;

    if (appointments.isEmpty && !controller.isLoading.value) {
      return _buildEmptyState(context);
    }

    return Column(
      mainAxisSize: MainAxisSize.min, // ✅ Added
      children: [
        ...appointments.map((appointment) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AppointmentCard(
              appointment: appointment,
              onTap: () =>
                  controller.navigateToAppointmentDetail(appointment.id),
              onReschedule: () => controller.navigateToReschedule(appointment),
              onCancel: () => controller.cancelAppointment(appointment),
              onPayNow: () => controller.markPaymentAsPaid(appointment),
              onRate: () => controller.rateAppointment(appointment),
            ),
          );
        }),
        if (controller.hasMoreData.value)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: controller.isLoadingMore.value
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: cs.primary,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        if (!controller.hasMoreData.value && appointments.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              TranslationKeys.appointmentsShowingCount.tr
                  .replaceAll('@shown', '${appointments.length}')
                  .replaceAll('@total', '${controller.totalCount.value}'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            ),
          ),
      ],
    );
  }

  // ==================== EMPTY STATE ====================

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min, // ✅ Added
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.event_busy_rounded, size: 40, color: cs.primary),
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyTitle(),
              style: TextStyle(
                fontSize: textScale.scale(16).clamp(14.0, 18.0),
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
                fontFamily: 'PlayfairDisplay',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptySubtitle(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: textScale.scale(12).clamp(10.0, 14.0),
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.navigateToFindDoctors,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(TranslationKeys.appointmentsBookAppointment.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== LOADING STATE ====================

  Widget _buildLoadingState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: cs.primary,
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            TranslationKeys.appointmentsLoading.tr,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ERROR STATE ====================

  Widget _buildErrorState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // ✅ Added
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: cs.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              TranslationKeys.commonSomethingWentWrong.tr,
              style: TextStyle(
                fontSize: textScale.scale(16).clamp(14.0, 18.0),
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: textScale.scale(12).clamp(10.0, 14.0),
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(TranslationKeys.commonTryAgain.tr),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== FLOATING ACTION BUTTON ====================

  // Widget _buildFAB(BuildContext context) {
  //   final cs = Theme.of(context).colorScheme;

  //   return FloatingActionButton.extended(
  //     onPressed: controller.navigateToBookAppointment,
  //     backgroundColor: cs.primary,
  //     foregroundColor: cs.onPrimary,
  //     elevation: 4,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  //     icon: const Icon(Icons.add_circle_rounded, size: 20),
  //     label: Text(
  //       TranslationKeys.appointmentsBookAppointment.tr,
  //       style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
  //     ),
  //   );
  // }

  // ==================== HELPERS ====================

  IconData _getFilterIcon(AppointmentFilter filter) {
    switch (filter) {
      case AppointmentFilter.all:
        return Icons.calendar_view_week_rounded;
      case AppointmentFilter.pending:
        return Icons.hourglass_empty_rounded;
      case AppointmentFilter.confirmed:
        return Icons.check_circle_rounded;
      case AppointmentFilter.unpaid:
        return Icons.schedule_rounded;
      default:
        return Icons.calendar_view_week_rounded;
    }
  }

  String _getEmptyTitle() {
    switch (controller.selectedFilter.value) {
      case AppointmentFilter.all:
        return TranslationKeys.appointmentsNoFound.tr;
      case AppointmentFilter.pending:
        return TranslationKeys.appointmentsNoPending.tr;
      case AppointmentFilter.confirmed:
        return TranslationKeys.appointmentsNoConfirmed.tr;
      case AppointmentFilter.unpaid:
        return TranslationKeys.appointmentsNoUnpaid.tr;
      default:
        return TranslationKeys.appointmentsNoFound.tr;
    }
  }

  String _getEmptySubtitle() {
    switch (controller.selectedFilter.value) {
      case AppointmentFilter.all:
        return TranslationKeys.appointmentsSubAll.tr;
      case AppointmentFilter.pending:
        return TranslationKeys.appointmentsSubPending.tr;
      case AppointmentFilter.confirmed:
        return TranslationKeys.appointmentsSubConfirmed.tr;
      case AppointmentFilter.unpaid:
        return TranslationKeys.appointmentsSubUnpaid.tr;
      default:
        return TranslationKeys.appointmentsSubAll.tr;
    }
  }
}
