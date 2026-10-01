// lib/patient/features/emergency/screens/emergency_screen.dart

import 'package:doctor/core/localization/translation_keys.dart';
import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:doctor/patient/features/emergency/controllers/emergency_controller.dart';
import 'package:doctor/patient/features/emergency/models/nearby_hospital.dart';
import 'package:doctor/patient/features/emergency/models/patient_sos_event.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmergencyScreen extends GetView<EmergencyController> {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: PatientTopAppBar(title: TranslationKeys.sosTitle.tr),
      body: Column(
        children: [
          // ── Tab switcher ──────────────────────────────────────────────
          Obx(
            () => Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  // ✅ Dark mode: gradient card to match other screens
                  gradient: isDark
                      ? LinearGradient(
                          begin: AlignmentDirectional.topStart,
                          end: AlignmentDirectional.bottomEnd,
                          colors: [
                            colors.primary.withOpacity(0.10),
                            colors.primaryContainer.withOpacity(0.06),
                          ],
                        )
                      : null,
                  color: !isDark ? colors.surfaceContainerLowest : null,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? colors.primary.withOpacity(0.12)
                        : colors.outlineVariant,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    _tab(
                      context,
                      TranslationKeys.sosTab.tr,
                      Icons.emergency_rounded,
                      0,
                    ),
                    _tab(
                      context,
                      TranslationKeys.sosHospitals.tr,
                      Icons.local_hospital_rounded,
                      1,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ── Content ───────────────────────────────────────────────────
          Expanded(
            child: Obx(
              () => controller.selectedSection.value == 0
                  ? _sosTab(context)
                  : _hospitalTab(context),
            ),
          ),
        ],
      ),
      // ── FAB ────────────────────────────────────────────────────────────
      floatingActionButton: Obx(
        () => controller.selectedSection.value == 0
            ? FloatingActionButton.extended(
                onPressed: () async {
                  final result = await Get.toNamed(AppRoutes.generateSos);
                  if (result == true) controller.loadSos(refresh: true);
                },
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
                elevation: 3,
                icon: const Icon(Icons.sos_rounded),
                label: Text(
                  TranslationKeys.sosGenerate.tr,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              )
            : FloatingActionButton(
                onPressed: controller.isLoadingHospitals.value
                    ? null
                    : () => controller.loadHospitals(refresh: true),
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                elevation: 3,
                tooltip: 'Refresh hospitals',
                child: controller.isLoadingHospitals.value
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: colors.onPrimary,
                        ),
                      )
                    : const Icon(Icons.refresh_rounded),
              ),
      ),
    );
  }

  // ── Tab ──────────────────────────────────────────────────────────────────
  Widget _tab(BuildContext context, String label, IconData icon, int index) {
    final colors = Theme.of(context).colorScheme;
    final selected = controller.selectedSection.value == index;
    final activeColor = index == 0 ? colors.error : colors.primary;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          controller.selectedSection.value = index;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected ? colors.onPrimary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? colors.onPrimary
                        : colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── SOS Tab ───────────────────────────────────────────────────────────────
  Widget _sosTab(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingSos.value && controller.sosEvents.isEmpty)
        return _loading(context);
      if (controller.hasSosError.value && controller.sosEvents.isEmpty) {
        return _error(
          context,
          controller.sosError.value,
          () => controller.loadSos(refresh: true),
        );
      }
      return RefreshIndicator(
        onRefresh: () => controller.loadSos(refresh: true),
        color: Theme.of(context).colorScheme.error,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            _sectionHeader(
              context,
              TranslationKeys.sosActive.tr,
              controller.activeEvents.length,
              isActive: true,
            ),
            const SizedBox(height: 8),
            if (controller.activeEvents.isEmpty)
              _emptyState(
                context,
                icon: Icons.check_circle_outline_rounded,
                message: TranslationKeys.sosNoActive.tr,
                submessage: TranslationKeys.sosAllClear.tr,
              )
            else
              ...controller.activeEvents.map(
                (event) => _sosCard(context, event),
              ),
            const SizedBox(height: 24),
            _sectionHeader(
              context,
              TranslationKeys.sosPrevious.tr,
              controller.previousEvents.length,
              isActive: false,
            ),
            const SizedBox(height: 8),
            if (controller.previousEvents.isEmpty)
              _emptyState(
                context,
                icon: Icons.history_rounded,
                message: TranslationKeys.sosNoPrevious.tr,
                submessage: TranslationKeys.sosHistory.tr,
              )
            else
              ...controller.previousEvents.map(
                (event) => _sosCard(context, event),
              ),
          ],
        ),
      );
    });
  }

  // ── SOS Card ──────────────────────────────────────────────────────────────
  Widget _sosCard(BuildContext context, PatientSosEvent event) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = event.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        // ✅ Dark mode: gradient card; Light: solid surface
        gradient: isDark
            ? LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: isActive
                    ? [
                        colors.error.withOpacity(0.12),
                        colors.errorContainer.withOpacity(0.06),
                      ]
                    : [
                        colors.primary.withOpacity(0.10),
                        colors.primaryContainer.withOpacity(0.06),
                      ],
              )
            : null,
        color: isActive
            ? colors.errorContainer.withOpacity(0.10)
            : (!isDark ? colors.surface : null),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? colors.error.withOpacity(isDark ? 0.4 : 0.30)
              : (isDark
                    ? colors.primary.withOpacity(0.12)
                    : colors.outlineVariant),
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? colors.error.withOpacity(0.08)
                : (isDark
                      ? colors.shadow.withOpacity(0.05)
                      : Colors.black.withOpacity(0.04)),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isActive)
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: colors.error,
                borderRadius: const BorderRadiusDirectional.only(
                  topStart: Radius.circular(16),
                  topEnd: Radius.circular(16),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: event.statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.emergency_rounded,
                        color: event.statusColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _statusPill(event, colors),
                          const SizedBox(height: 3),
                          Text(
                            _date(event.createdAt),
                            style: TextStyle(
                              fontSize: 11.5,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ── Notes ──
                if (event.notes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? colors.primary.withOpacity(0.15)
                          : colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                      border: Border(
                        left: BorderSide(
                          color: isDark
                              ? colors.primary.withOpacity(0.5)
                              : colors.onSurfaceVariant.withOpacity(0.35),
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      event.notes,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : colors.onSurface,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],

                if (event.latitude != null && event.longitude != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${event.latitude!.toStringAsFixed(4)}, '
                          '${event.longitude!.toStringAsFixed(4)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                if (isActive) ...[
                  const SizedBox(height: 14),
                  Divider(height: 1, color: colors.outlineVariant),
                  const SizedBox(height: 10),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: OutlinedButton.icon(
                      onPressed: controller.isResolving.value
                          ? null
                          : () => controller.resolveSos(event, 'false_alarm'),
                      icon: const Icon(Icons.cancel_outlined, size: 15),
                      label: Text(TranslationKeys.sosCancelAlert.tr),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.error,
                        side: BorderSide(color: colors.error.withOpacity(0.45)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(PatientSosEvent event, ColorScheme colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color: event.statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (event.isActive) ...[
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: colors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
              ],
              Text(
                event.statusLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: event.statusColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Hospitals Tab ─────────────────────────────────────────────────────────
  Widget _hospitalTab(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingHospitals.value && controller.hospitals.isEmpty)
        return _loading(context);
      if (controller.hasHospitalError.value && controller.hospitals.isEmpty)
        return _error(
          context,
          controller.hospitalError.value,
          controller.loadHospitals,
        );
      if (controller.hospitals.isEmpty)
        return RefreshIndicator(
          onRefresh: controller.loadHospitals,
          child: ListView(
            children: [
              _emptyState(
                context,
                icon: Icons.local_hospital_outlined,
                message: TranslationKeys.sosNoHospitals.tr,
                submessage: TranslationKeys.sosCheckLocation.tr,
              ),
            ],
          ),
        );
      return RefreshIndicator(
        onRefresh: controller.loadHospitals,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          itemCount: controller.hospitals.length,
          itemBuilder: (_, index) =>
              _hospitalTile(context, controller.hospitals[index]),
        ),
      );
    });
  }

  Widget _hospitalTile(BuildContext context, NearbyHospital hospital) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [
                  colors.primary.withOpacity(0.10),
                  colors.primaryContainer.withOpacity(0.06),
                ],
              )
            : null,
        color: !isDark ? colors.surface : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? colors.primary.withOpacity(0.12)
              : colors.outlineVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? colors.shadow.withOpacity(0.05)
                : Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark
                    ? colors.primary.withOpacity(0.2)
                    : colors.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.local_hospital_rounded,
                color: isDark ? colors.primaryFixed : colors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Name row with distance chip ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          hospital.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: colors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hospital.distanceMeters != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            hospital.distanceLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 13,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          hospital.address,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.onSurfaceVariant,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  // ── Rating + Open-now row ──
                  if (hospital.rating != null ||
                      hospital.isOpenNow != null) ...[
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        if (hospital.rating != null) ...[
                          Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: Colors.amber.shade600,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            hospital.rating!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                        ],
                        if (hospital.isOpenNow != null) ...[
                          if (hospital.rating != null)
                            const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: hospital.isOpenNow!
                                  ? Colors.green.withOpacity(0.15)
                                  : colors.errorContainer.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              hospital.isOpenNow! ? 'Open now' : 'Closed',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: hospital.isOpenNow!
                                    ? Colors.green.shade700
                                    : colors.error,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────

  Widget _sectionHeader(
    BuildContext context,
    String title,
    int count, {
    required bool isActive,
  }) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isActive && count > 0
                ? (isDark
                      ? colors.error.withOpacity(0.2)
                      : colors.errorContainer)
                : (isDark
                      ? colors.surfaceContainerHigh
                      : colors.surfaceContainerHigh),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isActive && count > 0
                  ? (isDark ? colors.error : colors.onErrorContainer)
                  : colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyState(
    BuildContext context, {
    required IconData icon,
    required String message,
    required String submessage,
  }) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.primary.withOpacity(0.15),
                        colors.primaryContainer.withOpacity(0.08),
                      ],
                    )
                  : null,
              color: !isDark ? colors.surfaceContainerHigh : null,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isDark ? colors.primary : colors.onSurfaceVariant,
              size: 26,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            submessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _loading(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(child: CircularProgressIndicator(color: colors.primary));
  }

  Widget _error(BuildContext context, String message, VoidCallback retry) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colors.errorContainer.withOpacity(0.40),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                color: colors.error,
                size: 26,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: retry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(TranslationKeys.commonRetry.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _date(DateTime date) =>
      '${date.day}/${date.month}/${date.year} '
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}
