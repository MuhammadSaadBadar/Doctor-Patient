import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/core/services/storage_service.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/bottom_nav_bar.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';
import 'package:doctor/core/widgets/top_app_bar.dart';
import 'package:doctor/doctor/features/patient/controllers/doc_diet_plans_controller.dart';
import 'package:doctor/doctor/features/patient/models/doc_diet_plan.dart';
import 'package:doctor/doctor/features/patient/widgets/doc_diet_plan_card.dart';
import 'package:doctor/doctor/features/patient/widgets/doc_diet_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorDietPlansScreen extends GetView<DoctorDietPlansController> {
  const DoctorDietPlansScreen({super.key});

  bool get _isDoctorOrAdmin {
    final role = StorageService.instance.userRole?.toLowerCase();
    return role == 'doctor' || role == 'admin';
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? colorScheme.background
          : colorScheme.surfaceContainerLowest,
      // Use shared TopAppNavBar with FAB for creating new diet plan
      appBar: TopAppNavBar.gradient(
        title: 'Diet Plans',
        height: 64,
        showBackButton: true,
        onProfileTap: () async {
          final result = await Get.toNamed(
            AppRoutes.doccreateDietPlan,
            arguments: {'patientId': controller.patientId},
          );
          if (result == true) {
            controller.refreshPlans();
          }
        },
        profileInitials: '+',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.toNamed(
            AppRoutes.doccreateDietPlan,
            arguments: {'patientId': controller.patientId},
          );
          if (result == true) {
            controller.refreshPlans();
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshPlans,
        color: AppColors.primary,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32.0 : 16.0,
            vertical: 8.0,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: Obx(() {
              if (controller.isLoading.value && controller.plans.isEmpty) {
                return _buildLoadingState(context); // ✅ Fixed
              }

              if (controller.hasError.value) {
                return _buildErrorState(context);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  _buildSummarySection(context), // ✅ Fixed
                  const SizedBox(height: 24),

                  // Filters & Sort
                  _buildFiltersAndSort(context), // ✅ Fixed
                  const SizedBox(height: 24),

                  // Diet Plans List
                  _buildDietPlansList(context), // ✅ Fixed
                  const SizedBox(height: 16),

                  // Load More
                  _buildLoadMoreButton(context), // ✅ Fixed
                  const SizedBox(height: 16),
                ],
              );
            }),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Loading diet plans...',
            style: AppTheme.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MaterialSymbolIcon(
            'error_outline',
            size: 64,
            color: colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            controller.errorMessage.value,
            style: AppTheme.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => controller.refreshPlans(),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summaryBgColor = isDark ? colorScheme.secondary : colorScheme.primary;
    return Obx(() {
      final activeCount = controller.plans
          .where((p) => p.status == DietPlanStatus.active)
          .length;
      final inactiveCount = controller.plans
          .where((p) => p.status == DietPlanStatus.inactive)
          .length;

      return Row(
        children: [
          Expanded(
            child: DietSummaryCard(
              label: 'Active Plans',
              value: '$activeCount',
              icon: 'restaurant_menu',
              iconColor: colorScheme.onSecondary,
              bgColor: summaryBgColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DietSummaryCard(
              label: 'Inactive',
              value: '$inactiveCount',
              icon: 'inventory_2',
              iconColor: colorScheme.onSecondary,
              bgColor: summaryBgColor,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildFiltersAndSort(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        // Filter buttons
        Obx(
          () => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', null, colorScheme, isDark),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Active',
                  DietPlanStatus.active,
                  colorScheme,
                  isDark,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Inactive',
                  DietPlanStatus.inactive,
                  colorScheme,
                  isDark,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Sort button
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: controller.toggleSort,
                child: Row(
                  children: [
                    MaterialSymbolIcon(
                      'sort',
                      size: 18,
                      color: colorScheme.primaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      controller.sortByDate.value ? 'Date Added' : 'Calories',
                      style: AppTheme.labelMedium.copyWith(
                        color: colorScheme.primaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    DietPlanStatus? status,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final isSelected = controller.selectedFilter.value == status;
    return GestureDetector(
      onTap: () {
        controller.setFilter(isSelected ? null : status);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? (isSelected ? colorScheme.primary : Colors.white)
              : (isSelected
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerLowest),
          borderRadius: BorderRadius.circular(9999),
          border: isDark
              ? null
              : (isSelected
                    ? null
                    : Border.all(color: colorScheme.outlineVariant, width: 1)),
        ),
        child: Text(
          label,
          style: AppTheme.labelMedium.copyWith(
            color: isDark
                ? (isSelected ? colorScheme.onPrimary : colorScheme.onSurface)
                : (isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }

  Widget _buildDietPlansList(BuildContext context) {
    return Obx(() {
      if (controller.filteredPlans.isEmpty) {
        return _buildEmptyState(context); // ✅ Fixed
      }

      return Column(
        children: controller.filteredPlans.map((plan) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: DietPlanCard(
              plan: plan,
              onTap: () async {
                final result = await Get.toNamed(
                  AppRoutes.doceditDietPlan,
                  arguments: {
                    'planId': plan.id,
                    'isEditing': true,
                    'patientId': plan.patientId ?? controller.patientId,
                  },
                );
                if (result == true) {
                  controller.refreshPlans();
                }
              },
              showDelete: _isDoctorOrAdmin,
              onDelete: _isDoctorOrAdmin
                  ? () async {
                      final confirmed = await _showDeleteConfirmation(
                        context,
                        plan,
                      );
                      if (confirmed == true) {
                        final success = await controller.deletePlan(plan.id);
                        if (success) {
                          Get.snackbar(
                            'Success',
                            'Diet plan deleted successfully.',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        } else {
                          Get.snackbar(
                            'Error',
                            'Failed to delete diet plan.',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: AppColors.error,
                            colorText: AppColors.onError,
                          );
                        }
                      }
                    }
                  : null,
            ),
          );
        }).toList(),
      );
    });
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context, DietPlan plan) {
    final colorScheme = Theme.of(context).colorScheme;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Plan ${plan.planNumber}?'),
        content: Text(
          'This action cannot be undone. The diet plan will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: colorScheme.primary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: colorScheme.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFiltered = controller.selectedFilter.value != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialSymbolIcon(
              isFiltered ? 'filter_alt_off' : 'search',
              size: 64,
              color: colorScheme.outline.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered ? 'No matching diet plans' : 'No diet plans found',
              style: AppTheme.headlineSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Try adjusting your filters'
                  : 'Create a new diet plan for this patient',
              style: AppTheme.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            if (isFiltered)
              ElevatedButton(
                onPressed: () {
                  controller.setFilter(null);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Clear Filters'),
              )
            else
              ElevatedButton(
                onPressed: () async {
                  final result = await Get.toNamed(
                    AppRoutes.doccreateDietPlan,
                    arguments: {'patientId': controller.patientId},
                  );
                  if (result == true) {
                    controller.refreshPlans();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Create Diet Plan'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
        );
      }

      if (!controller.hasMoreData.value && controller.plans.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Showing all ${controller.totalCount.value} diet plans',
              style: AppTheme.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }

      if (!controller.hasMoreData.value) {
        return const SizedBox.shrink();
      }

      return Center(
        child: ElevatedButton(
          onPressed: controller.loadMore,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.surfaceContainerLowest,
            foregroundColor: colorScheme.primaryContainer,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9999),
              side: BorderSide(color: colorScheme.primaryContainer, width: 1),
            ),
            textStyle: AppTheme.labelMedium,
          ),
          child: const Text('Load More Plans'),
        ),
      );
    });
  }
}
