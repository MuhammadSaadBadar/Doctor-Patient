// lib/doctor/features/auth/screens/otp_verification_screen.dart

import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';
import 'package:doctor/core/widgets/doc_top_app_bar.dart';
import 'package:doctor/doctor/features/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpVerificationScreen extends GetView<AuthController> {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            TopAppNavBar(
              title: 'OTP Verification',
              subtitle:
                  'Enter the 6-digit code sent to your registered email address.',
              centerTitle: true,
            ),
            const SizedBox(height: 24),
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min, // ✅ Added
                    children: [
                      // Brand Icon
                      _buildBrandIcon(),
                      const SizedBox(height: 32),
                      // OTP Input Form
                      _buildOtpForm(),
                      const SizedBox(height: 24),
                      // Back to Login
                      _buildBackToLoginButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
          Icons.enhanced_encryption_rounded,
          size: 48,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildOtpForm() {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // OTP Input Fields — ✅ FIXED: Removed Expanded, using SizedBox instead
          _buildOtpInputFields(),
          const SizedBox(height: 24),
          // Timer & Resend
          _buildTimerAndResend(),
          const SizedBox(height: 24),
          // Verify Button
          _buildVerifyButton(),
        ],
      ),
    );
  }

  Widget _buildOtpInputFields() {
    // ✅ FIXED: Removed Expanded, using SizedBox with fixed height
    return SizedBox(
      height: 56, // Fixed height for the OTP row
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SizedBox(
                width: 48, // Fixed width for each OTP box
                height: 56,
                child: TextFormField(
                  controller: controller.otpControllers[index],
                  focusNode: controller.otpFocusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: AppTheme.headlineMedium.copyWith(
                    color: AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.surfaceContainerLowest,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.surfaceVariant,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.surfaceVariant,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.length == 1 && index < 5) {
                      FocusScope.of(Get.context!).nextFocus();
                    } else if (value.isEmpty && index > 0) {
                      FocusScope.of(Get.context!).previousFocus();
                    }
                    if (index == 5 && value.length == 1) {
                      _handleVerifyOtp();
                    }
                  },
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTimerAndResend() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MaterialSymbolIcon(
                'schedule',
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                controller.formatTime(controller.timerSeconds.value),
                style: AppTheme.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (controller.timerSeconds.value <= 0) ...[
            const SizedBox(width: 16),
            TextButton(
              onPressed: controller.isLoading.value ? null : _handleResendOtp,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: AppTheme.labelMedium,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Resend OTP'),
            ),
          ],
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
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: AppTheme.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
            disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
          ),
          child: controller.isOtpLoading.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.onPrimary,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text('Verify OTP'),
        ),
      ),
    );
  }

  Widget _buildBackToLoginButton() {
    return TextButton.icon(
      onPressed: () {
        controller.clearOtpFields();
        Get.offAllNamed(AppRoutes.login);
      },
      icon: MaterialSymbolIcon(
        'arrow_back_rounded',
        size: 18,
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
    final email = Get.arguments?['email'] ?? controller.emailController.text;
    return email;
  }

  void _handleVerifyOtp() {
    String otp = '';
    for (var ctrl in controller.otpControllers) {
      otp += ctrl.text;
    }

    if (otp.length == 6) {
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
