// lib/patient/features/kick_counter/screens/kick_counter_screen.dart

import 'package:doctor/core/localization/translation_keys.dart';
import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:doctor/patient/features/kick_counter/controllers/kick_counter_controller.dart';
import 'package:doctor/patient/features/kick_counter/widgets/kick_counter_display.dart';
import 'package:doctor/patient/features/kick_counter/widgets/kick_history_item.dart';
import 'package:doctor/patient/features/kick_counter/widgets/kick_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KickCounterScreen extends GetView<KickCounterController> {
  const KickCounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: PatientTopAppBar(
        title: TranslationKeys.kickCounterTitle.tr,
        onNotificationTap: () => Get.toNamed('/notifications'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.allSessions.isEmpty) {
          return _buildLoadingState(context);
        }

        if (controller.hasError.value && controller.allSessions.isEmpty) {
          return _buildErrorState(context);
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              MediaQuery.of(context).padding.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title Section
                _buildTitleSection(context),

                const SizedBox(height: 24),

                // Kick Counter Display
                Obx(
                  () => KickCounterDisplay(
                    kickCount: controller.activeSession.value?.kickCount ?? 0,
                    onAdd: controller.recordKick,
                    onRemove: () {
                      // Remove last kick (not supported by API)
                      Get.snackbar(
                        TranslationKeys.kickCounterInfo.tr,
                        TranslationKeys.kickCounterRemoveComingSoon.tr,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    isActive: controller.activeSession.value != null,
                  ),
                ),

                const SizedBox(height: 12),

                // Status Badge
                Obx(
                  () => KickStatusBadge(
                    isActive: controller.activeSession.value != null,
                    kickCount: controller.activeSession.value?.kickCount,
                  ),
                ),

                const SizedBox(height: 8),

                // Session Controls
                Obx(() {
                  if (controller.isSessionActive) {
                    return _buildEndSessionButton(context);
                  }
                  return _buildStartSessionButton(context);
                }),

                const SizedBox(height: 16),

                // Recent History
                _buildHistorySection(context),
              ],
            ),
          ),
        );
      }),
      // bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          TranslationKeys.kickCounterTitle.tr,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          TranslationKeys.kickCounterNoSessionsDesc.tr,
          style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildStartSessionButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isProcessing.value
            ? null
            : controller.startSession,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: controller.isProcessing.value
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: colorScheme.onPrimary,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                TranslationKeys.kickCounterStart.tr,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }

  Widget _buildEndSessionButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: controller.isProcessing.value ? null : controller.endSession,
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.error,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: colorScheme.error.withOpacity(0.5)),
        ),
        child: controller.isProcessing.value
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: colorScheme.error,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.stop_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    TranslationKeys.kickCounterEnd.tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Get today's sessions and recent history
    final sessions = controller.allSessions;
    final displaySessions = sessions.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.04),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 20,
                    color: colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    TranslationKeys.kickCounterRecentHistory.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: controller.navigateToHistory,
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                ),
                child: Text(TranslationKeys.kickCounterViewAll.tr),
              ),
            ],
          ),
          if (displaySessions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  TranslationKeys.kickCounterNoSessions.tr,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
            )
          else
            Column(
              children: displaySessions.map((session) {
                return KickHistoryItem(session: session);
              }).toList(),
            ),
        ],
      ),
    );
  }
  // Widget _buildBottomNav(BuildContext context) {
  //     final colorScheme = Theme.of(context).colorScheme;

  //     return Container(
  //       decoration: BoxDecoration(
  //         color: colorScheme.surface.withOpacity(0.9),
  //         boxShadow: [
  //           BoxShadow(
  //             color: colorScheme.shadow.withOpacity(0.05),
  //             blurRadius: 20,
  //             offset: const Offset(0, -4),
  //           ),
  //         ],
  //         borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
  //       ),
  //       child: SafeArea(
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceAround,
  //             children: [
  //               _buildNavItem(
  //                 context,
  //                 icon: Icons.home_rounded,
  //                 label: 'Home',
  //                 onTap: controller.navigateToHome,
  //                 isActive: false,
  //               ),
  //               _buildNavItem(
  //                 context,
  //                 icon: Icons.event_rounded,
  //                 label: 'Booking',
  //                 onTap: controller.navigateToBooking,
  //                 isActive: false,
  //               ),
  //               _buildNavItem(
  //                 context,
  //                 icon: Icons.description_rounded,
  //                 label: 'Reports',
  //                 onTap: controller.navigateToReports,
  //                 isActive: false,
  //               ),
  //               _buildNavItem(
  //                 context,
  //                 icon: Icons.history_rounded,
  //                 label: 'History',
  //                 onTap: controller.navigateToHistory,
  //                 isActive: true,
  //               ),
  //               _buildNavItem(
  //                 context,
  //                 icon: Icons.person_rounded,
  //                 label: 'Profile',
  //                 onTap: controller.navigateToProfile,
  //                 isActive: false,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),

  //     );
  //   }

  //   Widget _buildNavItem(
  //     BuildContext context, {
  //     required IconData icon,
  //     required String label,
  //     required VoidCallback onTap,
  //     required bool isActive,
  //   }) {
  //     final colorScheme = Theme.of(context).colorScheme;

  //     return GestureDetector(
  //       onTap: onTap,
  //       child: Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
  //         decoration: BoxDecoration(
  //           color: isActive
  //               ? colorScheme.primaryContainer.withOpacity(0.15)
  //               : Colors.transparent,
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Icon(
  //               icon,
  //               color: isActive ? colorScheme.primary : colorScheme.outline,
  //               size: 24,
  //             ),
  //             const SizedBox(height: 2),
  //             Flexible(
  //               child: Text(
  //                 label,
  //                 maxLines: 1,
  //                 overflow: TextOverflow.ellipsis,
  //                 style: TextStyle(
  //                   fontSize: 10,
  //                   fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
  //                   color: isActive ? colorScheme.primary : colorScheme.outline,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }

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
            TranslationKeys.commonLoading.tr,
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
              TranslationKeys.commonSomethingWentWrong.tr,
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
              child: Text(TranslationKeys.commonTryAgain.tr),
            ),
          ],
        ),
      ),
    );
  }
}
