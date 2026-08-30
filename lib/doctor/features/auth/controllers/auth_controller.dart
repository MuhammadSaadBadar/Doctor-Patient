import 'dart:async';

import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/constants/user_role.dart';
import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/doctor/features/auth/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final AuthRepository _repository = AuthRepository();

  // ============ Login Controllers ============
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final obscurePassword = true.obs;

  // Old password change controllers
  final oldPasswordController = TextEditingController();
  final oldPasswordFocusNode = FocusNode();

  // Login state
  final isLoggedIn = false.obs;

  // ============ Forgot Password ============
  final forgotPasswordEmailController = TextEditingController();

  // ============ OTP Controllers ============
  final otpControllers = List.generate(6, (_) => TextEditingController());
  final otpFocusNodes = List.generate(6, (_) => FocusNode());
  final timerSeconds = 120.obs;
  Timer? _timer;

  // ============ Reset Password Controllers ============
  final resetNewPasswordController = TextEditingController();
  final resetConfirmPasswordController = TextEditingController();
  final resetPasswordFormKey = GlobalKey<FormState>();
  final resetNewPasswordFocusNode = FocusNode();
  final resetConfirmPasswordFocusNode = FocusNode();

  // Reset Password Visibility
  final obscureResetNewPassword = true.obs;
  final obscureResetConfirmPassword = true.obs;

  // Reset Password Validation
  final resetIsLengthValid = false.obs;
  final resetHasUppercase = false.obs;
  final resetHasNumber = false.obs;
  final resetHasSpecialChar = false.obs;

  // Reset token from OTP verification
  final resetToken = ''.obs;

  // ============ Change Password Controllers ============
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final changePasswordFormKey = GlobalKey<FormState>();
  final newPasswordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  // Change Password Visibility
  final obscureNewPassword = true.obs;
  final obscureConfirmPassword = true.obs;

  // Change Password Validation
  final isLengthValid = false.obs;
  final hasUppercase = false.obs;
  final hasNumber = false.obs;

  // ============ Loading States ============
  final isLoading = false.obs;
  final isOtpLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _startTimer();
  }

  @override
  void onClose() {
    // Dispose Login controllers
    emailController.dispose();
    passwordController.dispose();

    // Dispose Forgot Password controllers
    forgotPasswordEmailController.dispose();

    // Dispose OTP controllers
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in otpFocusNodes) {
      node.dispose();
    }

    // Dispose Reset Password controllers
    resetNewPasswordController.dispose();
    resetConfirmPasswordController.dispose();
    resetNewPasswordFocusNode.dispose();
    resetConfirmPasswordFocusNode.dispose();

    // Dispose Change Password controllers
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    newPasswordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();

    _timer?.cancel();
    super.onClose();
  }

  // ============ Login Methods ============
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // ============ FCM Token ============
  Future<void> updateFcmToken(String token) async {
    try {
      await _repository.updateFcmToken(token);
      debugPrint('[AUTH] FCM token updated successfully');
    } catch (e) {
      debugPrint('[AUTH] Failed to update FCM token: $e');
    }
  }

  // ============ Login Methods ============
  Future<void> login(
    String email,
    String password, {
    UserRole? preferredRole,
  }) async {
    isLoading.value = true;
    try {
      final result = await _repository.login(email, password);
      if (result.success && result.role != null) {
        // TODO: Get FCM token from Firebase Messaging when package is added
        // final fcmToken = await FirebaseMessaging.instance.getToken();
        // if (fcmToken != null) await updateFcmToken(fcmToken);

        // Route based on actual role from backend, not selected role
        if (result.role == UserRole.doctor) {
          Get.offAllNamed(AppRoutes.docdashboard);
        } else {
          Get.offAllNamed(AppRoutes.patientDashboard);
        }
      } else {
        // Show the actual error message from backend
        Get.snackbar(
          'Login Failed',
          result.errorMessage ?? 'Invalid email or password. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.error,
          colorText: AppColors.onError,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
        duration: const Duration(seconds: 3),
      );
      debugPrint('[AUTH] Login unexpected error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============ Forgot Password Methods ============
  Future<void> forgotPassword(String email) async {
    isLoading.value = true;
    try {
      final success = await _repository.resetPassword(email);
      if (success) {
        Get.toNamed(
          AppRoutes.otpVerification,
          arguments: {'email': email, 'purpose': 'reset'},
        );
        Get.snackbar(
          'OTP Sent',
          'A verification code has been sent to your email',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.secondary,
          colorText: AppColors.onPrimary,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to send reset instructions. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.error,
          colorText: AppColors.onError,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ============ OTP Methods ============
  Future<void> verifyOtp(String otp, String email) async {
    isOtpLoading.value = true;
    try {
      final result = await _repository.verifyOtpForReset(email, otp);
      if (result) {
        resetToken.value = _repository.getResetToken ?? '';
        _timer?.cancel();
        Get.toNamed(AppRoutes.resetPassword);
      } else {
        Get.snackbar(
          'Invalid OTP',
          'Please enter the correct verification code',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.error,
          colorText: AppColors.onError,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'OTP verification failed. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
      );
    } finally {
      isOtpLoading.value = false;
    }
  }

  Future<void> resendOtp(String email) async {
    if (timerSeconds.value > 0) return;

    isLoading.value = true;
    try {
      final success = await _repository.resendResetOtp(email);
      if (success) {
        _startTimer();
        Get.snackbar(
          'OTP Sent',
          'A new verification code has been sent to your email',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.secondary,
          colorText: AppColors.onPrimary,
        );
        for (var controller in otpControllers) {
          controller.clear();
        }
        if (otpFocusNodes.isNotEmpty) {
          otpFocusNodes[0].requestFocus();
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to resend OTP. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.error,
          colorText: AppColors.onError,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ============ Reset Password Methods ============
  void toggleResetNewPasswordVisibility() {
    obscureResetNewPassword.value = !obscureResetNewPassword.value;
  }

  void toggleResetConfirmPasswordVisibility() {
    obscureResetConfirmPassword.value = !obscureResetConfirmPassword.value;
  }

  void validateResetPasswordStrength(String password) {
    resetIsLengthValid.value = password.length >= 8;
    resetHasUppercase.value = RegExp(r'[A-Z]').hasMatch(password);
    resetHasNumber.value = RegExp(r'[0-9]').hasMatch(password);
    resetHasSpecialChar.value = RegExp(
      r'[!@#$%^&*(),.?":{}|<>]',
    ).hasMatch(password);
  }

  Future<void> resetPasswordWithToken(String token, String newPassword) async {
    isLoading.value = true;
    try {
      final success = await _repository.resetPasswordWithToken(
        token,
        newPassword,
      );
      if (success) {
        resetToken.value = '';
        Get.offAllNamed(AppRoutes.passwordResetSuccess);
      } else {
        Get.snackbar(
          'Error',
          'Failed to reset password. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.error,
          colorText: AppColors.onError,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ============ Change Password Methods ============
  void toggleNewPasswordVisibility() {
    obscureNewPassword.value = !obscureNewPassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  void validatePasswordStrength(String password) {
    isLengthValid.value = password.length >= 8;
    hasUppercase.value = RegExp(r'[A-Z]').hasMatch(password);
    hasNumber.value = RegExp(r'[0-9]').hasMatch(password);
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    isLoading.value = true;
    try {
      final success = await _repository.changePassword(
        oldPassword,
        newPassword,
      );
      if (success) {
        Get.back();
        Get.snackbar(
          'Success',
          'Password changed successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.success,
          colorText: AppColors.onPrimary,
        );
        newPasswordController.clear();
        confirmPasswordController.clear();
        isLengthValid.value = false;
        hasUppercase.value = false;
        hasNumber.value = false;
      } else {
        Get.snackbar(
          'Error',
          'Failed to change password. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.error,
          colorText: AppColors.onError,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ============ Timer Methods ============
  void _startTimer() {
    _timer?.cancel();
    timerSeconds.value = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerSeconds.value > 0) {
        timerSeconds.value--;
      } else {
        timer.cancel();
      }
    });
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
