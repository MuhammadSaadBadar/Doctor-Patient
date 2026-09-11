import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/localization/translation_keys.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';
import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:doctor/patient/features/settings/controllers/patient_settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PatientChangePasswordScreen
    extends GetView<PatientSettingsController> {
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          PatientTopAppBar(
            title: TranslationKeys.settingsChangePassword.tr,
            showBackButton: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
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
        Text(
          TranslationKeys.settingsChangePassword.tr,
          style: AppTheme.getResponsiveHeadline(Get.context!)
              .copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Update your password to keep your account secure.',
            textAlign: TextAlign.center,
            style: AppTheme.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
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
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.onPrimary,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      textStyle: AppTheme.labelMedium,
                      disabledBackgroundColor:
                          AppColors.primaryContainer.withOpacity(0.6),
                      shadowColor: AppColors.primary.withOpacity(0.15),
                    ),
                    child: _controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.onPrimary,
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
    );
  }

  Widget _buildPasswordRequirements() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password must contain:',
              style: AppTheme.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet
                ? Icons.check_box
                : Icons.check_box_outline_blank,
            size: 18,
            color: isMet ? AppColors.success : AppColors.outline,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTheme.bodySmall.copyWith(
              color: isMet ? AppColors.success : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMapper() {
    return Obx(
      () {
        final error = _controller.changePasswordError.value;
        if (error.isEmpty) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.errorContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.error, width: 1),
          ),
          child: Text(
            error,
            style: AppTheme.bodySmall.copyWith(color: AppColors.onErrorContainer),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
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
            border: Border.all(color: AppColors.outlineVariant, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  obscureText: obscureText,
                  validator: validator,
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
                ),
              ),
              IconButton(
                onPressed: onToggleVisibility,
                icon: MaterialSymbolIcon(
                  obscureText ? 'visibility_off' : 'visibility',
                  size: 20,
                  color: AppColors.onSurfaceVariant,
                ),
                padding: const EdgeInsetsDirectional.only(end: 12),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
