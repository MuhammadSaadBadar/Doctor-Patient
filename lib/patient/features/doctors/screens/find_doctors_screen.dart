// lib/patient/features/doctors/screens/find_doctors_screen.dart

import 'package:doctor/core/localization/translation_keys.dart';
import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:doctor/patient/features/doctors/controllers/doctor_controller.dart';
import 'package:doctor/patient/features/doctors/widgets/doctor_card.dart';
import 'package:doctor/patient/features/doctors/widgets/specialization_chip.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FindDoctorsScreen extends GetView<DoctorController> {
  const FindDoctorsScreen({super.key});

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // ✅ surface — already correct in original
      backgroundColor: colorScheme.background,
      appBar: PatientTopAppBar(
        title: TranslationKeys.doctorsFindDoctors.tr,
        onNotificationTap: controller.navigateToNotifications,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.doctors.isEmpty) {
          return _buildLoadingState(context);
        }
        if (controller.hasError.value && controller.doctors.isEmpty) {
          return _buildErrorState(context);
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: colorScheme.primary,
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildWelcomeSection(context),
                  const SizedBox(height: 16),
                  _buildSearchBar(context),
                  const SizedBox(height: 12),
                  _buildSpecializationFilters(context),
                  const SizedBox(height: 16),
                  _buildDoctorList(context),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          TranslationKeys.doctorsFindExpertCare.tr,
          style: TextStyle(
            fontSize: textScale.scale(24).clamp(18.0, 32.0),
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          TranslationKeys.doctorsCareSubtitle.tr,
          style: TextStyle(
            fontSize: textScale.scale(14).clamp(12.0, 18.0),
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = _isDark(context);
    final textScale = MediaQuery.textScalerOf(context);

    return Obx(
      () => TextField(
        onChanged: controller.setSearchQuery,
        decoration: InputDecoration(
          hintText: TranslationKeys.doctorsSearchHint.tr,
          hintStyle: TextStyle(
            // ✅ Hint reads on both themes
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
          suffixIcon: controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: controller.clearSearch,
                )
              : null,
          filled: true,
          // ✅ Dark: elevated lifted surface; Light: subtle neutral
          fillColor: isDark
              ? colorScheme.surfaceContainerHigh
              : colorScheme.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: isDark
                ? BorderSide(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    width: 1,
                  )
                : BorderSide.none,
          ),
          enabledBorder: isDark
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    width: 1,
                  ),
                )
              : null,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: textScale.scale(12).clamp(10.0, 16.0),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecializationFilters(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Obx(
        () => ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.specializations.length,
          itemBuilder: (context, index) {
            final spec = controller.specializations[index];
            return Obx(() {
              final isSelected =
                  controller.selectedSpecialization.value == spec;

              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: SpecializationChip(
                  label: spec,
                  isSelected: isSelected,
                  onTap: () => controller.setSpecialization(spec),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  Widget _buildDoctorList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Obx(() {
      final displayDoctors = controller.filteredDoctors;

      if (displayDoctors.isEmpty && !controller.isLoading.value) {
        return _buildEmptyState(context);
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...displayDoctors.map((doctor) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DoctorCard(
                doctor: doctor,
                commissionPercentage: controller.commissionPercentage.value,
                onTap: () => controller.navigateToDoctorDetail(doctor.id),
                onBookTap: () =>
                    controller.navigateToBookAppointment(doctor.id),
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
                          color: colorScheme.primary,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          if (!controller.hasMoreData.value && displayDoctors.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                TranslationKeys.doctorsShowingExperts.tr.replaceAll(
                  '@count',
                  controller.totalCount.value.toString(),
                ),
                style: TextStyle(
                  fontSize: textScale.scale(12).clamp(10.0, 16.0),
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.medical_services_rounded,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            TranslationKeys.doctorsNoResults.tr,
            style: TextStyle(
              fontSize: textScale.scale(14).clamp(12.0, 18.0),
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            TranslationKeys.doctorsAdjustFilters.tr,
            style: TextStyle(
              fontSize: textScale.scale(12).clamp(10.0, 16.0),
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.clearSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(TranslationKeys.doctorsClearFilters.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(
                alpha: isDark ? 0.35 : 0.2,
              ),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            TranslationKeys.doctorsFindingExperts.tr,
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
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
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: textScale.scale(16).clamp(14.0, 20.0),
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: textScale.scale(12).clamp(10.0, 16.0),
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
