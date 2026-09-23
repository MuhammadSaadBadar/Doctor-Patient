// lib/patient/features/settings/screens/patient_change_password_screen.dart

import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/localization/translation_keys.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';
import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:doctor/patient/features/settings/controllers/patient_settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PatientChangePasswordScreen extends GetView<PatientSettingsController> {
  const PatientChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) => const _ChangePasswordView();
}

class _ChangePasswordView extends StatefulWidget {
  const _ChangePasswordView();

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _oldPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  PatientSettingsController get _controller =>
      Get.find<PatientSettingsController>();

  @override
  void initState() {
    super.initState();
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _newPasswordController.addListener(_onNewPasswordChanged);
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onNewPasswordChanged() {
    _controller.validatePasswordStrength(_newPasswordController.text);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await _controller.changePassword(
      oldPassword: _oldPasswordController.text.trim(),
      newPassword: _newPasswordController.text.trim(),
    );

    if (success && mounted) {
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      _controller.changePasswordError.value = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          PatientTopAppBar(
            title: TranslationKeys.settingsChangePassword.tr,
            showBackButton: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleSection(),
                  const SizedBox(height: 24),
                  _buildForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      // ✅ THE FIX — force center alignment
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ✅ Center the icon with SizedBox wrapper
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary.withOpacity(0.30),
                        colorScheme.primaryContainer.withOpacity(0.20),
                      ],
                    )
                  : null,
              color: !isDark ? colorScheme.primaryContainer : null,
              shape: BoxShape.circle,
              boxShadow: isDark
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Icon(
                Icons.enhanced_encryption,
                size: 32,
                color: isDark ? colorScheme.primaryFixed : colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // ✅ Center the title text
        Center(
          child: Text(
            TranslationKeys.settingsChangePassword.tr,
            textAlign: TextAlign.center,
            style: AppTheme.getResponsiveHeadline(Get.context!).copyWith(
              color: isDark ? colorScheme.primaryFixed : colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Update your password to keep your account secure.',
              textAlign: TextAlign.center,
              style: AppTheme.bodyMedium.copyWith(
                color: isDark
                    ? colorScheme.onSurfaceVariant.withOpacity(0.8)
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // ✅ Dark mode: gradient background matching other cards
        gradient: isDark
            ? LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [
                  colorScheme.primary.withOpacity(0.10),
                  colorScheme.primaryContainer.withOpacity(0.06),
                ],
              )
            : null,
        color: !isDark ? colorScheme.surfaceContainerLowest : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? colorScheme.primary.withOpacity(0.12)
              : colorScheme.outlineVariant,
          width: 1,
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current password
            _buildPasswordField(
              label: 'Current Password',
              controller: _oldPasswordController,
              hintText: 'Enter your current password',
              obscureText: _obscureOld,
              onToggleVisibility: () =>
                  setState(() => _obscureOld = !_obscureOld),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your current password';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // New password
            _buildPasswordField(
              label: 'New Password',
              controller: _newPasswordController,
              hintText: 'Enter new password',
              obscureText: _obscureNew,
              onToggleVisibility: () =>
                  setState(() => _obscureNew = !_obscureNew),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a new password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                  return 'Password must contain at least one uppercase letter';
                }
                if (!RegExp(r'[a-z]').hasMatch(value)) {
                  return 'Password must contain at least one lowercase letter';
                }
                if (!RegExp(r'[^A-Za-z0-9]').hasMatch(value)) {
                  return 'Password must contain at least one special character';
                }
                return null;
              },
            ),

            // Password requirements
            _buildPasswordRequirements(),

            const SizedBox(height: 16),

            // Confirm password
            _buildPasswordField(
              label: 'Confirm New Password',
              controller: _confirmPasswordController,
              hintText: 'Re-enter new password',
              obscureText: _obscureConfirm,
              onToggleVisibility: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your new password';
                }
                if (value != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Submit button
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _controller.isLoading.value ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        // ✅ Dark mode: primary pink; Light: primaryContainer
                        backgroundColor: isDark
                            ? colorScheme.primary
                            : colorScheme.primaryContainer,
                        foregroundColor: isDark
                            ? colorScheme.onPrimary
                            : colorScheme.onPrimary,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        textStyle: AppTheme.labelMedium,
                        disabledBackgroundColor: colorScheme.primary
                            .withOpacity(0.5),
                        shadowColor: colorScheme.primary.withOpacity(0.25),
                      ),
                      child: _controller.isLoading.value
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: colorScheme.onPrimary,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(TranslationKeys.commonSave.tr),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildErrorMapper(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password must contain:',
              style: AppTheme.bodySmall.copyWith(
                color: isDark
                    ? colorScheme.onSurfaceVariant.withOpacity(0.8)
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            _buildRequirementItem(
              'At least 8 characters',
              _controller.isLengthValid.value,
            ),
            _buildRequirementItem(
              'One uppercase letter',
              _controller.hasUppercase.value,
            ),
            _buildRequirementItem(
              'One lowercase letter',
              _controller.hasLowercase.value,
            ),
            _buildRequirementItem(
              'One special character',
              _controller.hasSpecial.value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ Use theme-aware success color
    final successColor = isDark
        ? const Color(0xFF6DB582) // Brighter green for dark mode
        : const Color(0xFF226B3F); // Darker green for light mode

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_box : Icons.check_box_outline_blank,
            size: 18,
            color: isMet ? successColor : colorScheme.outline,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTheme.bodySmall.copyWith(
              color: isMet
                  ? successColor
                  : (isDark
                        ? colorScheme.onSurfaceVariant.withOpacity(0.8)
                        : colorScheme.onSurfaceVariant),
              fontWeight: isMet ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMapper() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final error = _controller.changePasswordError.value;
      if (error.isEmpty) return const SizedBox.shrink();
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // ✅ Dark mode: darker error bg with visible border
          color: isDark
              ? colorScheme.error.withOpacity(0.15)
              : colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark
                ? colorScheme.error.withOpacity(0.5)
                : colorScheme.error,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 18,
              color: isDark ? colorScheme.error : colorScheme.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: AppTheme.bodySmall.copyWith(
                  color: isDark
                      ? colorScheme.error
                      : colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ Field background = colorScheme.background (light in dark mode)
    final fieldBgColor = colorScheme.background;

    // ✅ Text color = onBackground (dark in dark mode)
    final textColor = colorScheme.onBackground;

    // ✅ Hint color = onBackground with low opacity
    final hintColor = colorScheme.onBackground.withOpacity(0.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.labelMedium.copyWith(
            color: isDark ? colorScheme.primaryFixed : colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),

        // ✅ Outer container with background + border
        Container(
          decoration: BoxDecoration(
            color: fieldBgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark
                  ? colorScheme.primary.withOpacity(0.3)
                  : colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          // ✅ INNER container — same background + rounded clipping
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              // ✅ Same background color as the outer container
              color: fieldBgColor,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      obscureText: obscureText,
                      validator: validator,
                      style: AppTheme.bodyMedium.copyWith(color: textColor),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: AppTheme.bodyMedium.copyWith(
                          color: hintColor,
                        ),
                        // ✅ Remove any default fill from the TextField
                        filled: false,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onToggleVisibility,
                    icon: MaterialSymbolIcon(
                      obscureText ? 'visibility_off' : 'visibility',
                      size: 20,
                      color: colorScheme.onBackground.withOpacity(0.6),
                    ),
                    padding: const EdgeInsetsDirectional.only(end: 12),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
