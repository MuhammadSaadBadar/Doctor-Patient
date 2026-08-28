import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';
import 'package:doctor/core/widgets/top_app_bar.dart';
import 'package:doctor/features/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpVerificationScreen extends GetView<AuthController> {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Brand Icon
                  _buildBrandIcon(),
                  const SizedBox(height: 32),

                  // Header is now handled by TopAppNavBar
                  TopAppNavBar(
                    title: 'OTP Verification',
                    subtitle: 'Enter the 6-digit code sent to your registered email address.',
                    centerTitle: true,
                  ),
                  const SizedBox(height: 24),

                  // OTP Input Form
                  _buildOtpForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.enhanced_encryption,
          size: 48,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildOtpForm() {
    return Form(
      child: Column(
        children: [
          // OTP Input Fields
          _buildOtpInputFields(),
          const SizedBox(height: 16),

          // Timer & Resend
          _buildTimerAndResend(),
          const SizedBox(height: 24),

          // Verify Button
          _buildVerifyButton(),
          const SizedBox(height: 16),

          // Back to Login
          _buildBackToLoginButton(),
        ],
      ),
    );
  }

  Widget _buildOtpInputFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Container(
          width: 48,
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: TextFormField(
            controller: controller.otpControllers[index],
            focusNode: controller.otpFocusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: AppTheme.headlineMedium.copyWith(color: AppColors.primary),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.surfaceVariant,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.surfaceVariant,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.secondary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) {
              if (value.length == 1 && index < 5) {
                FocusScope.of(Get.context!).nextFocus();
              } else if (value.isEmpty && index > 0) {
                FocusScope.of(Get.context!).previousFocus();
              }
              // Auto-submit when all fields are filled
              if (index == 5 && value.length == 1) {
                _handleVerifyOtp();
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildTimerAndResend() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              MaterialSymbolIcon(
                'schedule',
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                controller.formatTime(controller.timerSeconds.value),
                style: AppTheme.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (controller.timerSeconds.value > 0)
            TextButton(
              onPressed: null,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.onSurfaceVariant.withOpacity(0.5),
                textStyle: AppTheme.labelMedium,
              ),
              child: const Text('Resend OTP'),
            )
          else
            TextButton(
              onPressed: controller.isLoading.value ? null : _handleResendOtp,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondary,
                textStyle: AppTheme.labelMedium,
              ),
              child: const Text('Resend OTP'),
            ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: controller.isOtpLoading.value ? null : _handleVerifyOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: AppColors.onPrimaryContainer,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: AppTheme.labelMedium,
            disabledBackgroundColor: AppColors.primaryContainer.withOpacity(
              0.6,
            ),
          ),
          child: controller.isOtpLoading.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.onPrimaryContainer,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Verify OTP'),
        ),
      ),
    );
  }

  Widget _buildBackToLoginButton() {
    return TextButton.icon(
      onPressed: () => Get.offAllNamed(AppRoutes.login),
      icon: MaterialSymbolIcon(
        'arrow_back',
        size: 16,
        color: AppColors.onSurfaceVariant,
      ),
      label: Text(
        'Back to Login',
        style: AppTheme.labelMedium.copyWith(color: AppColors.onSurfaceVariant),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  String _getEmail() {
    // Get email from arguments or from the controller
    final email = Get.arguments?['email'] ?? controller.emailController.text;
    return email;
  }

  void _handleVerifyOtp() {
    String otp = '';
    for (var controller in controller.otpControllers) {
      otp += controller.text;
    }

    if (otp.length == 6) {
      // Get email and pass to the verify method
      final email = _getEmail();
      controller.verifyOtp(otp, email);
    } else {
      Get.snackbar(
        'Invalid OTP',
        'Please enter all 6 digits',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _handleResendOtp() {
    final email = _getEmail();
    controller.resendOtp(email);
  }
}
