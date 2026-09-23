// lib/patient/features/surgical_procedures/screens/surgical_procedures_screen.dart

import 'package:doctor/patient/features/surgical_procedures/controllers/surgical_procedure_controller.dart';
import 'package:doctor/patient/features/surgical_procedures/widgets/procedure_card.dart';
import 'package:doctor/patient/features/surgical_procedures/widgets/procedure_empty_state.dart';
import 'package:doctor/patient/features/surgical_procedures/widgets/procedure_stat_card.dart';
import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SurgicalProceduresScreen extends GetView<SurgicalProcedureController> {
  const SurgicalProceduresScreen({super.key});

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _semanticFg(BuildContext context, Color base) {
    final isDark = _isDark(context);
    if (base == Colors.green)
      return isDark ? Colors.green.shade300 : Colors.green.shade800;
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // ✅ surface is correct here — already in the original code
      backgroundColor: colorScheme.background,
      appBar: PatientTopAppBar(
        title: 'Surgical History',
        trailingActions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: colorScheme.primary),
            onPressed: controller.openAddModal,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.procedures.isEmpty) {
          return _buildLoadingState(context, colorScheme);
        }

        if (controller.hasError.value && controller.procedures.isEmpty) {
          return _buildErrorState(context, colorScheme);
        }

        if (controller.isEmpty) {
          return ProcedureEmptyState(onAddTap: controller.openAddModal);
        }

        return _buildContent(context, colorScheme);
      }),
      floatingActionButton: _buildFAB(context, colorScheme),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme colorScheme) {
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
            children: [
              _buildStatsRow(context, colorScheme),
              const SizedBox(height: 20),
              _buildFilterTabs(context, colorScheme),
              const SizedBox(height: 16),
              _buildProcedureList(context, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, ColorScheme colorScheme) {
    final isDark = _isDark(context);
    final greenFg = _semanticFg(context, Colors.green);

    return Row(
      children: [
        Expanded(
          child: ProcedureStatCard(
            value: controller.totalProcedures.toString().padLeft(2, '0'),
            label: 'Total Procedures',
            icon: Icons.folder_off_rounded,
            iconColor: colorScheme.primary,
            // ✅ Tint bumped in dark
            backgroundColor: colorScheme.primary.withValues(
              alpha: isDark ? 0.20 : 0.1,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ProcedureStatCard(
            value: controller.thisYearCount.toString(),
            label: 'This Year',
            icon: Icons.schedule_rounded,
            iconColor: colorScheme.secondary,
            backgroundColor: colorScheme.secondary.withValues(
              alpha: isDark ? 0.20 : 0.1,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ProcedureStatCard(
            value: controller.lastRecordedDate,
            label: 'Last Recorded',
            icon: Icons.event_available_rounded,
            // ✅ Semantic green that flips with brightness
            iconColor: greenFg,
            backgroundColor: Colors.green.withValues(
              alpha: isDark ? 0.20 : 0.1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs(BuildContext context, ColorScheme colorScheme) {
    final isDark = _isDark(context);
    final textScale = MediaQuery.textScalerOf(context);

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          final isSelected = controller.selectedCategory.value == category;
          final count = controller.getCategoryCount(category);

          // ✅ Unselected chip — gradient in dark, surface in light
          final unselectedDecoration = BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.10),
                      colorScheme.primaryContainer.withValues(alpha: 0.06),
                    ],
                  )
                : null,
            color: !isDark ? colorScheme.surfaceContainerLowest : null,
            borderRadius: BorderRadius.circular(30),
            border: isDark
                ? Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.18),
                    width: 1,
                  )
                : null,
          );

          // ✅ Selected chip — solid primary + shadow
          final selectedDecoration = BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(
                  alpha: isDark ? 0.35 : 0.2,
                ),
                blurRadius: isDark ? 10 : 8,
                offset: const Offset(0, 2),
              ),
            ],
          );

          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: GestureDetector(
              onTap: () => controller.setCategory(category),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: textScale.scale(14).clamp(10.0, 20.0),
                  vertical: textScale.scale(6).clamp(4.0, 12.0),
                ),
                decoration: isSelected
                    ? selectedDecoration
                    : unselectedDecoration,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: textScale.scale(11).clamp(9.0, 14.0),
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          // ✅ Count badge tint bumped in dark
                          color: isSelected
                              ? colorScheme.onPrimary.withValues(alpha: 0.22)
                              : (isDark
                                    ? colorScheme.primary.withValues(
                                        alpha: 0.18,
                                      )
                                    : colorScheme.surfaceContainerHighest),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: textScale.scale(9).clamp(7.0, 12.0),
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurfaceVariant,
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

  Widget _buildProcedureList(BuildContext context, ColorScheme colorScheme) {
    final textScale = MediaQuery.textScalerOf(context);
    final procedures = controller.filteredProcedures;

    if (procedures.isEmpty && !controller.isLoading.value) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Text(
            'No procedures found in this category',
            style: TextStyle(
              fontSize: textScale.scale(12).clamp(10.0, 16.0),
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        ...procedures.map((procedure) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ProcedureCard(
              procedure: procedure,
              onEdit: () => controller.openEditModal(procedure),
              onDelete: () => controller.deleteProcedure(procedure),
            ),
          );
        }),
        if (controller.hasMoreData.value)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: controller.isLoading.value
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
        if (!controller.hasMoreData.value && procedures.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Showing all ${controller.totalCount.value} procedures',
              style: TextStyle(
                fontSize: textScale.scale(11).clamp(9.0, 15.0),
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFAB(BuildContext context, ColorScheme colorScheme) {
    return FloatingActionButton.extended(
      onPressed: controller.openAddModal,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      icon: const Icon(Icons.add_rounded, size: 22),
      label: const Text(
        'Add Procedure',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, ColorScheme colorScheme) {
    final textScale = MediaQuery.textScalerOf(context);
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
              // ✅ Stronger tint in dark
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
            'Loading procedures...',
            style: TextStyle(
              fontSize: textScale.scale(14).clamp(12.0, 18.0),
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ColorScheme colorScheme) {
    final textScale = MediaQuery.textScalerOf(context);

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
                // ✅ Correct contrast pair
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
