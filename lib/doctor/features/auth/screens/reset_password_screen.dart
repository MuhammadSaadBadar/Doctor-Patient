import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';
import 'package:doctor/core/widgets/doc_top_app_bar.dart';
import 'package:doctor/doctor/features/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordScreen extends GetView<AuthController> {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                TopAppNavBar(title: 'Reset Password', centerTitle: true),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildIcon(),
                        const SizedBox(height: 16),
                        _buildTitle(),
                        const SizedBox(height: 24),
                        _buildResetPasswordForm(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.primaryFixed,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: MaterialSymbolIcon(
          'lock_reset',
          size: 48,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'Create New Password',
          style: AppTheme.headlineMedium.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Text(
          'Your new password must be different from previously used passwords to ensure account security.',
          textAlign: TextAlign.center,
          style: AppTheme.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildResetPasswordForm() {
    return Form(
      key: controller.resetPasswordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // New Password Field
          _buildPasswordField(
            label: 'NEW PASSWORD',
            textController: controller.resetNewPasswordController,
            focusNode: controller.resetNewPasswordFocusNode,
            hintText: 'Enter new password',
            icon: 'lock',
            isNewPassword: true,
            onChanged: (value) {
              controller.validateResetPasswordStrength(value);
            },
          ),
          const SizedBox(height: 16),

          // Confirm Password Field
          _buildPasswordField(
            label: 'CONFIRM PASSWORD',
            textController: controller.resetConfirmPasswordController,
            focusNode: controller.resetConfirmPasswordFocusNode,
            hintText: 'Re-enter new password',
            icon: 'lock',
            isNewPassword: false,
          ),
          const SizedBox(height: 16),

          // Password Requirements
          _buildPasswordRequirements(),

          const SizedBox(height: 32),

          // Reset Password Button
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : _handleResetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: AppTheme.headlineSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  disabledBackgroundColor: AppColors.primaryContainer
                      .withOpacity(0.6),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppColors.onPrimary,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text('Reset Password'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController
    textController, // Changed from 'controller' to 'textController'
    required FocusNode focusNode,
    required String hintText,
    required String icon,
    required bool isNewPassword, // Added to determine which password field
    void Function(String)? onChanged,
  }) {
    return Obx(() {
      // Use the isNewPassword flag to determine which obscure value to use
      final obscureText = isNewPassword
          ? controller.obscureResetNewPassword.value
          : controller.obscureResetConfirmPassword.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.labelMedium.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: focusNode.hasFocus
                    ? const Color(0xFF00BFA5)
                    : AppColors.outlineVariant,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                MaterialSymbolIcon(icon, size: 20, color: AppColors.outline),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: textController, // Use textController here
                    focusNode: focusNode,
                    obscureText: obscureText,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppColors.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: AppTheme.bodyMedium.copyWith(
                        color: AppColors.outline.withOpacity(0.7),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 4,
                      ),
                      isDense: true,
                    ),
                    onChanged: onChanged,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (isNewPassword) {
                      controller.toggleResetNewPasswordVisibility();
                    } else {
                      controller.toggleResetConfirmPasswordVisibility();
                    }
                  },
                  icon: MaterialSymbolIcon(
                    obscureText ? 'visibility' : 'visibility_off',
                    size: 20,
                    color: AppColors.outline,
                  ),
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPasswordRequirements() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PASSWORD MUST CONTAIN:',
              style: AppTheme.labelMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            _buildRequirementItem(
              'At least 8 characters',
              controller.resetIsLengthValid.value,
            ),
            _buildRequirementItem(
              'At least one uppercase letter',
              controller.resetHasUppercase.value,
            ),
            _buildRequirementItem(
              'At least one number (0-9)',
              controller.resetHasNumber.value,
            ),
            _buildRequirementItem(
              'At least one special character (!@#\$%^&*)',
              controller.resetHasSpecialChar.value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          MaterialSymbolIcon(
            isMet ? 'check_circle' : 'radio_button_unchecked',
            size: 16,
            color: isMet ? const Color(0xFF00897B) : AppColors.outline,
            fill: isMet,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTheme.bodySmall.copyWith(
              color: isMet
                  ? const Color(0xFF00897B)
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _handleResetPassword() {
    final newPassword = controller.resetNewPasswordController.text;
    final confirmPassword = controller.resetConfirmPasswordController.text;

    // Validate fields
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Validate password strength
    if (!controller.resetIsLengthValid.value ||
        !controller.resetHasUppercase.value ||
        !controller.resetHasNumber.value ||
        !controller.resetHasSpecialChar.value) {
      Get.snackbar(
        'Weak Password',
        'Please make sure your password meets all requirements',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Validate password match
    if (newPassword != confirmPassword) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Get the reset token from controller
    final resetToken = controller.resetToken.value;
    if (resetToken.isEmpty) {
      Get.snackbar(
        'Error',
        'Invalid reset session. Please request a new reset code.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Call controller method with token and new password
    controller.resetPasswordWithToken(resetToken, newPassword);
  }
}
