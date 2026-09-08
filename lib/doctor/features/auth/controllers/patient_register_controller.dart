import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/doctor/features/auth/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PatientRegisterController extends GetxController {
  final AuthRepository _repository = AuthRepository();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final isSubmitting = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.toggle();
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  String? _validateEmail(String? value) {
    final required = _required(value, 'Email');
    if (required != null) return required;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(value) ||
        !RegExp(r'\d').hasMatch(value)) {
      return 'Use at least one letter and one number';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final required = _required(value, 'Phone number');
    if (required != null) return required;
    if (!RegExp(r'^\+?[0-9][0-9\s-]{7,19}$').hasMatch(value!.trim())) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  Future<void> submit(GlobalKey<FormState> formKey) async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Invalid password', 'Passwords do not match');
      return;
    }

    isSubmitting.value = true;
    try {
      final success = await _repository.register(
        email: emailController.text.trim(),
        password: passwordController.text,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        phoneNumber: phoneController.text.trim(),
      );
      if (!success) throw Exception('Registration failed. Please try again.');

      Get.toNamed(
        AppRoutes.otpVerification,
        arguments: {
          'email': emailController.text.trim(),
          'purpose': 'registration',
        },
      );
      Get.snackbar(
        'Verify your email',
        'A 6-digit verification code was sent to your email.',
        backgroundColor: AppColors.secondary,
        colorText: AppColors.onPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Registration failed',
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
