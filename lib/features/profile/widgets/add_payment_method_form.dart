// lib/features/profile/widgets/add_payment_method_form.dart

import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/features/profile/controllers/add_payment_method_controller.dart';
import 'package:doctor/features/profile/models/add_payment_method.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddPaymentMethodForm extends GetView<AddPaymentMethodController> {
  const AddPaymentMethodForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.selectedMethod.value) {
        case PayoutMethod.jazzcash:
          return _buildJazzCashForm();
        case PayoutMethod.easypaisa:
          return _buildEasyPaisaForm();
        case PayoutMethod.bank:
          return _buildBankForm();
      }
    });
  }

  Widget _buildJazzCashForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'JazzCash Details',
            style: AppTheme.headlineSmall.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Divider(color: AppColors.outlineVariant, height: 1),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'JazzCash Number *',
            controller: controller.jazzcashNumberController,
            error: controller.jazzcashNumberError,
            hint: 'e.g. 0300-1234567',
            icon: Icons.phone_android_rounded,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Account Title *',
            controller: controller.jazzcashAccountTitleController,
            error: controller.jazzcashAccountTitleError,
            hint: 'e.g. Dr. Ayesha Malik',
            icon: Icons.person_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildEasyPaisaForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EasyPaisa Details',
            style: AppTheme.headlineSmall.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Divider(color: AppColors.outlineVariant, height: 1),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'EasyPaisa Number *',
            controller: controller.easypaisaNumberController,
            error: controller.easypaisaNumberError,
            hint: 'e.g. 0311-7654321',
            icon: Icons.phone_android_rounded,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Account Title *',
            controller: controller.easypaisaAccountTitleController,
            error: controller.easypaisaAccountTitleError,
            hint: 'e.g. Dr. Ayesha Malik',
            icon: Icons.person_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildBankForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bank Details',
            style: AppTheme.headlineSmall.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Divider(color: AppColors.outlineVariant, height: 1),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Bank Name *',
            controller: controller.bankNameController,
            error: controller.bankNameError,
            hint: 'e.g. Meezan Bank',
            icon: Icons.account_balance_rounded,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Account Title *',
            controller: controller.bankAccountTitleController,
            error: controller.bankAccountTitleError,
            hint: 'e.g. Dr. Ayesha Malik',
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Account Number *',
            controller: controller.bankAccountNumberController,
            error: controller.bankAccountNumberError,
            hint: 'e.g. 01234567890123',
            icon: Icons.numbers_rounded,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'IBAN *',
            controller: controller.bankIbanController,
            error: controller.bankIbanError,
            hint: 'e.g. PK00MEZN0001234567890123',
            icon: Icons.barcode_reader,
            textCapitalization: TextCapitalization.characters,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required RxString error,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.labelMedium.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.onSurfaceVariant.withOpacity(0.5),
              ),
              prefixIcon: Icon(icon, size: 20, color: AppColors.outline),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.outlineVariant,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.outlineVariant,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.error, width: 2),
              ),
              errorText: error.value.isNotEmpty ? error.value : null,
              errorStyle: AppTheme.bodySmall.copyWith(
                color: AppColors.error,
                fontSize: 12,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
