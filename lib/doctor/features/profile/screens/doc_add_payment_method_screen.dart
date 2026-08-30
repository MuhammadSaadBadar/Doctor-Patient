// lib/features/profile/screens/add_payment_method_screen.dart

import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/top_app_bar.dart';
import 'package:doctor/doctor/features/profile/controllers/doc_add_payment_method_controller.dart';
import 'package:doctor/doctor/features/profile/models/doc_add_payment_method.dart';
import 'package:doctor/doctor/features/profile/widgets/add_payment_method_form.dart';
import 'package:doctor/doctor/features/profile/widgets/add_payment_method_option.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorAddPaymentMethodScreen
    extends GetView<DoctorAddPaymentMethodController> {
  const DoctorAddPaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          const TopAppNavBar.gradient(
            title: 'Add Payment Method',
            height: 64,
            showBackButton: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 32,
                vertical: 16,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selection section
                    _buildSelectionSection(),
                    const SizedBox(height: 16),
                    // Dynamic form
                    AddPaymentMethodForm(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Payment Method',
          style: AppTheme.headlineSmall.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose how you want to receive your payouts',
          style: AppTheme.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => Column(
            children: PayoutMethod.values.map((method) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AddPaymentMethodOption(
                  method: method,
                  isSelected: controller.selectedMethod.value == method,
                  onTap: () => controller.selectMethod(method),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.outlineVariant, width: 1),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: controller.isSaving.value
                  ? null
                  : controller.savePaymentMethod,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                disabledForegroundColor: AppColors.onPrimary.withOpacity(0.6),
              ),
              child: controller.isSaving.value
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.onPrimary,
                      ),
                    )
                  : const Text(
                      'Save Payment Method',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
