import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor/features/auth/controllers/auth_controller.dart';

class ForgotPasswordScreen extends GetView<AuthController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Background decorative elements
          _buildBackgroundDecorations(),

          // Main content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _ForgotPasswordForm(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        // Top left gradient circle
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 800,
            height: 800,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surfaceContainerLowest,
                  AppColors.surfaceContainerHigh.withOpacity(0.5),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.surfaceContainerHigh.withOpacity(0.3),
                  blurRadius: 100,
                  spreadRadius: 50,
                ),
              ],
            ),
          ),
        ),
        // Bottom right gradient circle
        Positioned(
          bottom: -100,
          right: -100,
          child: Container(
            width: 600,
            height: 600,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
                colors: [
                  AppColors.primaryFixed.withOpacity(0.3),
                  AppColors.surfaceContainerLowest.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryFixed.withOpacity(0.1),
                  blurRadius: 80,
                  spreadRadius: 40,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ForgotPasswordForm extends StatefulWidget {
  @override
  State<_ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<_ForgotPasswordForm> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendResetLink() {
    if (_emailController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email address',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text)) {
      Get.snackbar(
        'Error',
        'Please enter a valid email address',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    Get.find<AuthController>().forgotPassword(_emailController.text);
  }

  void _navigateBackToLogin() {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Medical icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryFixedDim,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.medical_services,
                size: 28,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Brand name
          Text(
            'Gynae Hub',
            style: AppTheme.labelMedium.copyWith(
              color: AppColors.primary,
              letterSpacing: 2,
              textBaseline: TextBaseline.alphabetic,
            ),
          ),
          const SizedBox(height: 24),

          // Heading
          Text(
            'Forgot Password?',
            style: AppTheme.getResponsiveHeadline(
              context,
            ).copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),

          // Instructions
          Text(
            'Enter the email address associated with your account and we\'ll send you a link to reset your password.',
            textAlign: TextAlign.center,
            style: AppTheme.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // Email field
          _buildEmailField(),
          const SizedBox(height: 24),

          // Submit button
          _buildSubmitButton(),
          const SizedBox(height: 24),

          // Back to login
          _buildBackToLoginButton(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: AppTheme.labelMedium.copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outlineVariant, width: 1),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              MaterialSymbolIcon(
                'mail',
                size: 20,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppColors.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'doctor@mamahealth.com',
                    hintStyle: AppTheme.bodyMedium.copyWith(
                      color: AppColors.outline,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 4,
                    ),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Obx(() {
        final isLoading = Get.find<AuthController>().isLoading.value;
        return ElevatedButton(
          onPressed: isLoading ? null : _handleSendResetLink,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: AppTheme.labelMedium.copyWith(fontSize: 14),
            disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.onPrimary,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Send Reset Link'),
                    const SizedBox(width: 8),
                    MaterialSymbolIcon(
                      'arrow_forward',
                      size: 18,
                      color: AppColors.onPrimary,
                    ),
                  ],
                ),
        );
      }),
    );
  }

  Widget _buildBackToLoginButton() {
    return GestureDetector(
      onTap: _navigateBackToLogin,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MaterialSymbolIcon(
            'arrow_back',
            size: 16,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            'Back to Login',
            style: AppTheme.labelMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
