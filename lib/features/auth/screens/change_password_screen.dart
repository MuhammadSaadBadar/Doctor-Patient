import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';
import 'package:doctor/core/widgets/top_app_bar.dart';
import 'package:doctor/features/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordScreen extends GetView<AuthController> {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            TopAppNavBar(
              title: 'Change Password',
              subtitle: 'Update your password to keep your account secure.',
              centerTitle: true,
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Section
                    _buildTitleSection(),
                    const SizedBox(height: 24),

                    // Form
                    _buildChangePasswordForm(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TITLE SECTION ====================
  Widget _buildTitleSection() {
    return Column(
      children: [
        // Icon
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primaryFixed,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.enhanced_encryption,
              size: 32,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          'Change Password',
          style: AppTheme.getResponsiveHeadline(
            Get.context!,
          ).copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 8),

        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Create a new, strong password to secure your clinical account.',
            textAlign: TextAlign.center,
            style: AppTheme.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

Widget _buildChangePasswordForm() {
    return Form(
      key: controller.changePasswordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Old Password
          _buildPasswordField(
            label: 'Old Password',
            textController: controller.oldPasswordController,
            focusNode: controller.oldPasswordFocusNode,
            hintText: 'Enter your current password',
            isNewPassword: true,
            onChanged: (value) {
              // Validate strength on new password only
            },
          ),
          const SizedBox(height: 16),

          // New Password
          _buildPasswordField(
            label: 'New Password',
            textController: controller.newPasswordController,
            focusNode: controller.newPasswordFocusNode,
            hintText: 'Enter new password',
            isNewPassword: true,
            onChanged: (value) {
              controller.validatePasswordStrength(value);
            },
          ),
          const SizedBox(height: 16),

          // Confirm Password
          _buildPasswordField(
            label: 'Confirm New Password',
            textController: controller.confirmPasswordController,
            focusNode: controller.confirmPasswordFocusNode,
            hintText: 'Re-enter new password',
            isNewPassword: false,
          ),
          const SizedBox(height: 32),

          // Change Password Button
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : _handleChangePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  textStyle: AppTheme.labelMedium,
                  disabledBackgroundColor: AppColors.primaryContainer
                      .withOpacity(0.6),
                  shadowColor: AppColors.primary.withOpacity(0.15),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.onPrimary,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Change Password'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController textController,
    required FocusNode focusNode,
    required String hintText,
    required bool isNewPassword,
    void Function(String)? onChanged,
  }) {
    return Obx(() {
      final obscureText = isNewPassword
          ? controller.obscureNewPassword.value
          : controller.obscureConfirmPassword.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.labelMedium.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceDim,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: focusNode.hasFocus
                    ? AppColors.secondary
                    : AppColors.outlineVariant,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: textController,
                    focusNode: focusNode,
                    obscureText: obscureText,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppColors.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: AppTheme.bodyMedium.copyWith(
                        color: AppColors.outline,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      isDense: true,
                    ),
                    onChanged: onChanged,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (isNewPassword) {
                      controller.toggleNewPasswordVisibility();
                    } else {
                      controller.toggleConfirmPasswordVisibility();
                    }
                  },
                  icon: MaterialSymbolIcon(
                    obscureText ? 'visibility_off' : 'visibility',
                    size: 20,
                    color: obscureText
                        ? AppColors.onSurfaceVariant
                        : AppColors.secondary,
                  ),
                  padding: const EdgeInsets.only(right: 12),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password must contain:',
              style: AppTheme.labelMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            _buildRequirementItem(
              'At least 8 characters',
              controller.isLengthValid.value,
            ),
            _buildRequirementItem(
              'One uppercase letter',
              controller.hasUppercase.value,
            ),
            _buildRequirementItem('One number', controller.hasNumber.value),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: isMet ? AppColors.secondary : AppColors.outline,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTheme.bodySmall.copyWith(
              color: isMet ? AppColors.secondary : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _handleChangePassword() {
    final newPassword = controller.newPasswordController.text;
    final confirmPassword = controller.confirmPasswordController.text;
    final oldPassword = controller.oldPasswordController.text;

    // Validate fields
    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
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
      );
      return;
    }

    // Validate password strength
    if (!controller.isLengthValid.value ||
        !controller.hasUppercase.value ||
        !controller.hasNumber.value) {
      Get.snackbar(
        'Weak Password',
        'Please make sure your password meets all requirements',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
      );
      return;
    }

    // Call controller method
    controller.changePassword(oldPassword, newPassword);
  }
}
