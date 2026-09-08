// lib/patient/features/doctors/screens/find_doctors_screen.dart

import 'package:doctor/patient/features/doctors/controllers/doctor_controller.dart';
import 'package:doctor/patient/features/doctors/widgets/doctor_card.dart';
import 'package:doctor/patient/features/doctors/widgets/specialization_chip.dart';
import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FindDoctorsScreen extends GetView<DoctorController> {
  const FindDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: PatientTopAppBar(
        title: 'Find Doctors',
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
      bottomNavigationBar: _buildBottomNav(context),
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
          'Find Expert Care',
          style: TextStyle(
            fontSize: textScale.scale(24).clamp(18.0, 32.0),
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Your journey deserves the best medical guidance.',
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
    final textScale = MediaQuery.textScalerOf(context);

    return Obx(
      () => TextField(
        onChanged: controller.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search by doctor or specialty...',
          hintStyle: TextStyle(
            color: colorScheme.outline.withValues(alpha: 0.6),
          ),
          prefixIcon: Icon(Icons.search_rounded, color: colorScheme.outline),
          suffixIcon: controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: colorScheme.outline),
                  onPressed: controller.clearSearch,
                )
              : null,
          filled: true,
          fillColor: colorScheme.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
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
    // ✅ Fixed: Use Container with height instead of SizedBox, and move Obx inside
    return Container(
      height: 44,
      child: Obx(
        () => ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.specializations.length,
          itemBuilder: (context, index) {
            final spec = controller.specializations[index];
            final isSelected = controller.selectedSpecialization.value == spec;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SpecializationChip(
                label: spec,
                isSelected: isSelected,
                onTap: () => controller.setSpecialization(spec),
              ),
            );
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
                'Showing all ${controller.totalCount.value} available experts in your area.',
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
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No doctors found',
            style: TextStyle(
              fontSize: textScale.scale(14).clamp(12.0, 18.0),
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
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
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.9),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
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
              Expanded(
                child: _buildNavItem(
                  context,
                  icon: Icons.home_rounded,
                  label: 'Home',
                  onTap: controller.navigateToHome,
                  isActive: false,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  context,
                  icon: Icons.event_rounded,
                  label: 'Booking',
                  onTap: () {},
                  isActive: true,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  context,
                  icon: Icons.description_rounded,
                  label: 'Reports',
                  onTap: controller.navigateToReports,
                  isActive: false,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  context,
                  icon: Icons.history_rounded,
                  label: 'History',
                  onTap: controller.navigateToHistory,
                  isActive: false,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  context,
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  onTap: controller.navigateToProfile,
                  isActive: false,
                ),
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
    final textScale = MediaQuery.textScalerOf(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: textScale.scale(8).clamp(4.0, 12.0),
          vertical: textScale.scale(4).clamp(2.0, 8.0),
        ),
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.primaryContainer.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? colorScheme.primary : colorScheme.outline,
              size: 26,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: textScale.scale(9).clamp(7.0, 12.0),
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? colorScheme.primary : colorScheme.outline,
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
              color: colorScheme.primaryContainer.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Finding experts...',
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
                color: colorScheme.error,
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
