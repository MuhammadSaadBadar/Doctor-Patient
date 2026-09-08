// lib/features/settings/screens/payment_methods_screen.dart

import 'package:doctor/doctor/features/settings/models/payment_method_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/doc_top_app_bar.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';
import 'package:doctor/doctor/features/profile/controllers/doc_profile_controller.dart';
// ============ ADD THIS IMPORT ============
import 'package:doctor/doctor/features/profile/models/doc_add_payment_method.dart';
// =========================================

class PaymentMethodsScreen extends GetView<DoctorProfileController> {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          const TopAppNavBar.gradient(
            title: 'Payment Methods',
            height: 64,
            showBackButton: true,
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState();
              }

              if (controller.hasError.value) {
                return _buildErrorState();
              }

              if (controller.paymentMethods.value == null) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: controller.refreshPaymentMethods,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 32,
                    vertical: 16,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ============ SECTION 1: MY PAYMENT METHOD ============
                          _buildMyPaymentMethodSection(),
                          const SizedBox(height: 24),

                          // ============ SECTION 2: PLATFORM PAYMENT METHODS ============
                          _buildPlatformPaymentMethodsSection(),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ============ SECTION 1: MY PAYMENT METHOD ============
  Widget _buildMyPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'My Payment Method',
              style: AppTheme.headlineSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            // Edit button
            OutlinedButton.icon(
              onPressed: _navigateToAddPaymentMethod,
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: const Text('Edit'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                textStyle: AppTheme.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          final myMethod = controller.myPaymentMethod.value;
          if (myMethod == null || myMethod.method == null) {
            return _buildNoMyMethodState();
          }
          return _buildMyMethodCard(myMethod);
        }),
      ],
    );
  }

  Widget _buildNoMyMethodState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.payment_rounded,
              size: 24,
              color: AppColors.onSurfaceVariant.withOpacity(0.5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No payment method set',
                  style: AppTheme.headlineSmall.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Add your payment method to receive payouts',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _navigateToAddPaymentMethod,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Add Method'),
          ),
        ],
      ),
    );
  }

  Widget _buildMyMethodCard(PaymentMethodDetails method) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Method name with status badge
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: method.method!.iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  method.method!.icon,
                  size: 20,
                  color: method.method!.iconColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  method.method!.displayName,
                  style: AppTheme.headlineSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 12,
                      color: Colors.green[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Active',
                      style: AppTheme.labelMedium.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.surfaceContainer, height: 1),
          const SizedBox(height: 12),

          // Details based on method type
          ..._buildMethodDetails(method),
        ],
      ),
    );
  }

  List<Widget> _buildMethodDetails(PaymentMethodDetails method) {
    switch (method.method) {
      case PayoutMethod.jazzcash:
        return [
          _buildMyDetailRow('Number', method.jazzcashNumber ?? 'N/A'),
          _buildMyDetailRow(
            'Account Title',
            method.jazzcashAccountTitle ?? 'N/A',
          ),
        ];
      case PayoutMethod.easypaisa:
        return [
          _buildMyDetailRow('Number', method.easypaisaNumber ?? 'N/A'),
          _buildMyDetailRow(
            'Account Title',
            method.easypaisaAccountTitle ?? 'N/A',
          ),
        ];
      case PayoutMethod.bank:
        return [
          _buildMyDetailRow('Bank Name', method.bankName ?? 'N/A'),
          _buildMyDetailRow('Account Title', method.bankAccountTitle ?? 'N/A'),
          _buildMyDetailRow(
            'Account Number',
            method.bankAccountNumber ?? 'N/A',
          ),
          if (method.bankIban != null && method.bankIban!.isNotEmpty)
            _buildMyDetailRow('IBAN', method.bankIban!),
        ];
      default:
        return [];
    }
  }

  Widget _buildMyDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodySmall.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ SECTION 2: PLATFORM PAYMENT METHODS ============
  Widget _buildPlatformPaymentMethodsSection() {
    final methods = controller.paymentMethods.value!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Platform Payment Methods',
              style: AppTheme.headlineSmall.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                'Read Only',
                style: AppTheme.labelSmall.copyWith(
                  color: AppColors.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Use these details to send consultation payments',
          style: AppTheme.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        // FIXED: Use PlatformPaymentMethod instead of PlatformPaymentMethods
        if (methods.hasJazzCash) _buildPlatformJazzCashCard(methods),
        if (methods.hasEasyPaisa) _buildPlatformEasyPaisaCard(methods),
        if (methods.hasBank) _buildPlatformBankCard(methods),
      ],
    );
  }

  // FIXED: Use PlatformPaymentMethod instead of PlatformPaymentMethods
  Widget _buildPlatformJazzCashCard(PlatformPaymentMethod methods) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.phone_android_rounded,
                    color: Colors.purple,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'JazzCash',
                  style: AppTheme.headlineSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPlatformDetailRow('Number', methods.jazzcashNumber ?? 'N/A'),
          _buildPlatformDetailRow(
            'Account Title',
            methods.jazzcashAccountTitle ?? 'N/A',
          ),
        ],
      ),
    );
  }

  // FIXED: Use PlatformPaymentMethod instead of PlatformPaymentMethods
  Widget _buildPlatformEasyPaisaCard(PlatformPaymentMethod methods) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.phone_android_rounded,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'EasyPaisa',
                  style: AppTheme.headlineSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPlatformDetailRow('Number', methods.easypaisaNumber ?? 'N/A'),
          _buildPlatformDetailRow(
            'Account Title',
            methods.easypaisaAccountTitle ?? 'N/A',
          ),
        ],
      ),
    );
  }

  // FIXED: Use PlatformPaymentMethod instead of PlatformPaymentMethods
  Widget _buildPlatformBankCard(PlatformPaymentMethod methods) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.account_balance_rounded,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  methods.bankName ?? 'Bank Transfer',
                  style: AppTheme.headlineSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPlatformDetailRow(
            'Account Title',
            methods.bankAccountTitle ?? 'N/A',
          ),
          _buildPlatformDetailRow(
            'Account Number',
            methods.bankAccountNumber ?? 'N/A',
          ),
          if (methods.bankIban != null && methods.bankIban!.isNotEmpty)
            _buildPlatformDetailRow('IBAN', methods.bankIban!),
        ],
      ),
    );
  }

  Widget _buildPlatformDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodySmall.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ STATE WIDGETS ============
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Loading payment methods...',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
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
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage.value,
              style: AppTheme.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: controller.refreshPaymentMethods,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.payment_rounded,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Payment Methods Available',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Platform payment methods will appear here.',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ============ FLOATING ACTION BUTTON ============
  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _navigateToAddPaymentMethod,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'Add Method',
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  // ============ NAVIGATION ============
  void _navigateToAddPaymentMethod() {
    Get.toNamed(AppRoutes.docaddPaymentMethod)?.then((result) {
      if (result == true) {
        controller.refreshPaymentMethods();
      }
    });
  }
}
