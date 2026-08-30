import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/bottom_nav_bar.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';
import 'package:doctor/core/widgets/side_nav.dart';
import 'package:doctor/core/widgets/top_app_bar.dart';
import 'package:doctor/doctor/features/patient/widgets/doc_patient_card_widget.dart';
import 'package:doctor/doctor/features/patient/controllers/doc_patient_management_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class DoctorPatientManagementScreen
    extends GetView<DoctorPatientManagementController> {
  const DoctorPatientManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Row(
        children: [
          if (isDesktop) const SideNav(currentRoute: AppRoutes.docpatients),
          Expanded(
            child: Column(
              children: [
                const TopAppNavBar.gradient(
                  title: 'Patients',
                  height: 64,
                  showBackButton: false,
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 32.0 : 16.0,
                      vertical: 16.0,
                    ),
                    child: Obx(() {
                      if (controller.isLoading.value &&
                          controller.allPatients.isEmpty) {
                        return _buildLoadingState(context);
                      }

                      if (controller.hasError.value) {
                        return _buildErrorState(context);
                      }

                      return _buildMainContent(context);
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  // ── Mobile search bar ─────────────────────────────────────────────────────

  Widget _buildMobileSearchBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.onBackground : AppColors.background,
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            MaterialSymbolIcon('search', size: 18, color: cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                onChanged: controller.updateSearchQuery,
                style: AppTheme.bodyMedium.copyWith(color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search patients…',
                  hintStyle: AppTheme.bodyMedium.copyWith(color: cs.outline),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            Obx(() {
              if (controller.searchQuery.value.isEmpty) {
                return const SizedBox(width: 14);
              }
              return GestureDetector(
                onTap: () => controller.updateSearchQuery(''),
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: cs.onSurfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 13,
                      color: cs.surfaceContainerLowest,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Loading ───────────────────────────────────────────────────────────────

  Widget _buildLoadingState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              color: cs.primary,
              backgroundColor: cs.outlineVariant,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading patients…',
            style: AppTheme.bodyMedium.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────

  Widget _buildErrorState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              controller.errorMessage.value,
              style: AppTheme.bodyMedium.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => controller.refreshPatients(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: AppTheme.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main content ──────────────────────────────────────────────────────────

  Widget _buildMainContent(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return RefreshIndicator(
      onRefresh: controller.refreshPatients,
      color: Theme.of(context).colorScheme.primary,
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isDesktop) _buildMobileSearchBar(context),
            SizedBox(height: 5),
            _buildHeader(context),
            const SizedBox(height: 16),
            Expanded(
              child: controller.filteredPatients.isEmpty
                  ? _buildEmptyState(context)
                  : _buildPatientGrid(context),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assigned Patients',
                style: AppTheme.getResponsiveHeadline(
                  context,
                ).copyWith(color: cs.primary, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${controller.filteredPatients.length} active cases',
                    style: AppTheme.labelMedium.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isDesktop)
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to add patient
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(
                'New Patient',
                style: AppTheme.labelLarge.copyWith(
                  color: cs.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Patient grid ──────────────────────────────────────────────────────────

  Widget _buildPatientGrid(BuildContext context) {
    // Use MaxCrossAxisExtent for adaptive column count with minimum card width
    // This prevents vertical overflow by allowing cards to grow vertically as needed
    final isMobile = MediaQuery.of(context).size.width < 600;
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisSpacing: 12,
        crossAxisSpacing: 16,
        // Fixed extent matching AppointmentCard natural height (~210dp)
        mainAxisExtent: isMobile ? 210 : 200,
      ),
      itemCount: controller.filteredPatients.length,
      itemBuilder: (context, index) {
        final patient = controller.filteredPatients[index];
        return PatientCardWidget(
          patient: patient,
          onTap: () {
            Get.toNamed(
              AppRoutes.docpatientDetail,
              arguments: {'patientId': patient.id},
            );
          },
        );
      },
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: MaterialSymbolIcon(
                  'search',
                  size: 40,
                  color: cs.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Obx(
              () => Text(
                controller.searchQuery.value.isEmpty
                    ? 'No patients assigned'
                    : 'No patients found',
                style: AppTheme.headlineSmall.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Text(
                controller.searchQuery.value.isEmpty
                    ? 'You have no patients assigned yet'
                    : 'Try adjusting your search term',
                style: AppTheme.bodyMedium.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Obx(
              () => controller.searchQuery.value.isNotEmpty
                  ? SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () => controller.updateSearchQuery(''),
                        icon: const Icon(Icons.close_rounded, size: 16),
                        label: const Text('Clear Search'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.primary,
                          backgroundColor: cs.primaryContainer.withOpacity(0.2),
                          side: BorderSide(color: cs.primary.withOpacity(0.30)),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: AppTheme.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
