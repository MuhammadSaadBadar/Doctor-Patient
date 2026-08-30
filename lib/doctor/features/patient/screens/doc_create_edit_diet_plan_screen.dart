import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';
import 'package:doctor/core/widgets/top_app_bar.dart';
import 'package:doctor/doctor/features/patient/controllers/doc_create_diet_plan_controller.dart';
import 'package:doctor/doctor/features/patient/models/doc_diet_plan_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorCreateEditDietPlanScreen
    extends GetView<DoctorCreateEditDietPlanController> {
  final String? planId;
  final bool isEditing;

  const DoctorCreateEditDietPlanScreen({
    super.key,
    this.planId,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get patient name from route arguments
    final args = Get.arguments;
    final patientName = args is Map
        ? (args['patientName'] as String? ?? '')
        : '';

    return Scaffold(
      backgroundColor: isDark
          ? colorScheme.background
          : colorScheme.surfaceContainerLowest,
      appBar: TopAppNavBar.gradient(
        title: isEditing ? 'Edit Diet Plan' : 'Create Diet Plan',
        height: 64,
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                    backgroundColor: colorScheme.outlineVariant,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading diet plan…',
                  style: AppTheme.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.formData.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
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
                    'Failed to load diet plan data.',
                    style: AppTheme.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Theme(
          data: AppTheme.lightTheme,
          child: Builder(
            builder: (lightContext) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32.0 : 16.0,
                  vertical: 20.0,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () => controller.patientIdError.value.isNotEmpty
                                ? Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: colorScheme.errorContainer,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: colorScheme.error,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline_rounded,
                                          color: colorScheme.error,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            controller.patientIdError.value,
                                            style: AppTheme.bodyMedium.copyWith(
                                              color: colorScheme.error,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          _buildDescriptionSection(lightContext),
                          const SizedBox(height: 20),
                          _buildHydrationSection(lightContext),
                          const SizedBox(height: 20),
                          _buildMealsSection(lightContext),
                          const SizedBox(height: 20),
                          _buildFoodsToAvoidSection(lightContext),
                          const SizedBox(height: 28),
                          _buildFormActions(lightContext),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  // ── Description ────────────────────────────────────────────────────
  Widget _buildDescriptionSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return _sectionCard(
      context: context,
      title: 'Description',
      icon: Icons.info_outline_rounded,
      child: _buildFormField(
        context: context,
        label: 'Description',
        child: TextFormField(
          initialValue: controller.formData.value?.description ?? '',
          style: AppTheme.bodyMedium.copyWith(color: colorScheme.onSurface),
          maxLines: 3,
          decoration: _getInputDecoration(
            context: context,
            hintText: 'Clinical reasoning or general overview…',
          ),
          onSaved: (value) {
            final current = controller.formData.value;
            if (current != null) {
              controller.formData.value = current.copyWith(description: value);
            }
          },
        ),
      ),
    );
  }

  // ── Hydration ────────────────────────────────────────────────────────────
  Widget _buildHydrationSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return _sectionCard(
      context: context,
      title: 'Hydration Recommendation',
      icon: Icons.water_drop_rounded,
      child: _buildFormField(
        context: context,
        label: 'Water Intake Goal (ml)',
        child: Obx(
          () => TextFormField(
            initialValue:
                controller.formData.value?.hydrationRecommendationMl
                    ?.toString() ??
                '',
            style: AppTheme.bodyMedium.copyWith(color: colorScheme.onSurface),
            keyboardType: TextInputType.number,
            decoration: _getInputDecoration(
              context: context,
              hintText: 'e.g., 2500',
              prefixIcon: MaterialSymbolIcon(
                'water_drop',
                size: 18,
                color: colorScheme.primary,
              ),
              suffixText: 'ml',
              helperText: controller.hydrationGlasses.value.isNotEmpty
                  ? controller.hydrationGlasses.value
                  : null,
            ),
            onChanged: controller.updateHydrationRecommendation,
            onSaved: (value) {
              final current = controller.formData.value;
              if (current != null) {
                controller.formData.value = current.copyWith(
                  hydrationRecommendationMl: int.tryParse(value ?? ''),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  // ── Meals ─────────────────────────────────────────────────────────────────
  Widget _buildMealsSection(BuildContext context) {
    return _sectionCard(
      context: context,
      title: 'Meals',
      icon: Icons.restaurant_rounded,
      trailing: _buildAddButton(
        context: context,
        label: 'Add Meal',
        onPressed: controller.addMeal,
      ),
      child: Obx(() {
        final meals = controller.formData.value?.meals ?? [];
        if (meals.isEmpty) {
          return _buildEmptyRow(
            context: context,
            message: 'No meals added. Tap "Add Meal" to create one.',
          );
        }
        return Column(
          children: meals.asMap().entries.map((entry) {
            return _buildMealItem(context, entry.key, entry.value);
          }).toList(),
        );
      }),
    );
  }

  Widget _buildMealItem(BuildContext context, int index, DietPlanMeal meal) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 400;
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
          ),
          child: isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMealTypeDropdown(context, index, meal),
                    const SizedBox(height: 8),
                    _buildMealDescriptionField(context, index, meal),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildRemoveButton(
                        context: context,
                        onPressed: () => controller.removeMeal(index),
                      ),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildMealTypeDropdown(context, index, meal),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: _buildMealDescriptionField(context, index, meal),
                    ),
                    const SizedBox(width: 4),
                    _buildRemoveButton(
                      context: context,
                      onPressed: () => controller.removeMeal(index),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildMealTypeDropdown(
    BuildContext context,
    int index,
    DietPlanMeal meal,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return DropdownButtonFormField<String>(
      value: meal.mealType.isNotEmpty ? meal.mealType : null,
      hint: Text(
        'Meal Type',
        style: AppTheme.bodyMedium.copyWith(color: colorScheme.outline),
      ),
      items: controller.mealTypes.map((type) {
        final displayText = type.isNotEmpty
            ? '${type[0].toUpperCase()}${type.substring(1)}'
            : type;
        return DropdownMenuItem(
          value: type,
          child: Text(
            displayText,
            style: AppTheme.bodyMedium.copyWith(color: colorScheme.onSurface),
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          controller.updateMeal(index, value, meal.description);
        }
      },
      decoration: _dropdownDecoration(context),
      style: AppTheme.bodyMedium.copyWith(color: colorScheme.onSurface),
    );
  }

  Widget _buildMealDescriptionField(
    BuildContext context,
    int index,
    DietPlanMeal meal,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      initialValue: meal.description,
      style: AppTheme.bodyMedium.copyWith(color: colorScheme.onSurface),
      decoration: _getInputDecoration(
        context: context,
        hintText: 'Meal description',
      ),
      onChanged: (value) {
        controller.updateMeal(index, meal.mealType, value);
      },
    );
  }

  // ── Foods to avoid ────────────────────────────────────────────────────────────────
  Widget _buildFoodsToAvoidSection(BuildContext context) {
    return _sectionCard(
      context: context,
      title: 'Foods to Avoid',
      icon: Icons.no_food_rounded,
      trailing: _buildAddButton(
        context: context,
        label: 'Add Food',
        onPressed: controller.addFoodToAvoid,
      ),
      child: Obx(() {
        final foods = controller.formData.value?.foodsToAvoid ?? [];
        if (foods.isEmpty) {
          return _buildEmptyRow(
            context: context,
            message: 'No foods to avoid added. Tap "Add Food" to create one.',
          );
        }
        return Column(
          children: foods.asMap().entries.map((entry) {
            return _buildFoodToAvoidItem(context, entry.key, entry.value);
          }).toList(),
        );
      }),
    );
  }

  Widget _buildFoodToAvoidItem(
    BuildContext context,
    int index,
    DietPlanFoodAvoidance food,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 400;
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
          ),
          child: isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: food.foodName,
                      style: AppTheme.bodyMedium.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      decoration: _getInputDecoration(
                        context: context,
                        hintText: 'Food name',
                      ),
                      onChanged: (value) {
                        controller.updateFoodToAvoid(index, value, food.reason);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: food.reason,
                      style: AppTheme.bodyMedium.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      decoration: _getInputDecoration(
                        context: context,
                        hintText: 'Reason to avoid',
                      ),
                      onChanged: (value) {
                        controller.updateFoodToAvoid(
                          index,
                          food.foodName,
                          value,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildRemoveButton(
                        context: context,
                        onPressed: () => controller.removeFoodToAvoid(index),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: food.foodName,
                        style: AppTheme.bodyMedium.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        decoration: _getInputDecoration(
                          context: context,
                          hintText: 'Food name',
                        ),
                        onChanged: (value) {
                          controller.updateFoodToAvoid(
                            index,
                            value,
                            food.reason,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        initialValue: food.reason,
                        style: AppTheme.bodyMedium.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        decoration: _getInputDecoration(
                          context: context,
                          hintText: 'Reason to avoid',
                        ),
                        onChanged: (value) {
                          controller.updateFoodToAvoid(
                            index,
                            food.foodName,
                            value,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    _buildRemoveButton(
                      context: context,
                      onPressed: () => controller.removeFoodToAvoid(index),
                    ),
                  ],
                ),
        );
      },
    );
  }

  // ── Form actions ─────────────────────────────────────────────────────────
  Widget _buildFormActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
                backgroundColor: colorScheme.primaryContainer,
                side: BorderSide(color: colorScheme.primary.withOpacity(0.30)),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: AppTheme.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 10),
          Obx(
            () => SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: controller.isSaving.value
                    ? null
                    : controller.savePlan,
                icon: controller.isSaving.value
                    ? SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : MaterialSymbolIcon(
                        'save',
                        size: 18,
                        color: colorScheme.onPrimary,
                      ),
                label: Text(
                  controller.isSaving.value ? 'Saving…' : 'Save Plan',
                  style: AppTheme.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onPrimary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: colorScheme.primary.withOpacity(
                    0.55,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────
  Widget _sectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, size: 16, color: colorScheme.primary),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        title,
                        style: AppTheme.headlineSmall.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing],
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: colorScheme.primary.withOpacity(0.2)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildAddButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppTheme.labelMedium.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRemoveButton({
    required BuildContext context,
    required VoidCallback onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.close_rounded, color: colorScheme.error, size: 15),
        ),
      ),
    );
  }

  Widget _buildEmptyRow({
    required BuildContext context,
    required String message,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 24,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTheme.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required BuildContext context,
    required String label,
    bool isRequired = false,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTheme.labelMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: AppTheme.bodyMedium.copyWith(color: colorScheme.error),
              ),
          ],
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _getInputDecoration({
    required BuildContext context,
    required String hintText,
    Widget? prefixIcon,
    String? suffixText,
    String? helperText,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTheme.bodyMedium.copyWith(color: colorScheme.outline),
      prefixIcon: prefixIcon != null
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: prefixIcon,
            )
          : null,
      prefixIconConstraints: const BoxConstraints(minWidth: 40),
      suffixText: suffixText,
      suffixStyle: AppTheme.bodySmall.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
      helperText: helperText,
      helperStyle: AppTheme.bodySmall.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
      filled: true,
      fillColor: colorScheme.surfaceContainerHigh,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      isDense: true,
      errorStyle: AppTheme.bodySmall.copyWith(color: colorScheme.error),
    );
  }

  InputDecoration _dropdownDecoration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      filled: true,
      fillColor: colorScheme.surfaceContainerHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      isDense: true,
    );
  }
}
