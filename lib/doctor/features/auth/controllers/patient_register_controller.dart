import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/network/api_exceptions.dart';
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
    } on ApiException catch (e) {
      if (e is NetworkException) {
        _handleUnknownRegistrationOutcome();
        return;
      }

      if (_isExistingEmailError(e)) {
        Get.snackbar(
          'Account already exists',
          _registrationErrorMessage(e),
          backgroundColor: AppColors.error,
          colorText: AppColors.onError,
          duration: const Duration(seconds: 7),
          snackPosition: SnackPosition.BOTTOM,
          mainButton: TextButton(
            onPressed: _openVerificationRecovery,
            child: const Text(
              'Verify email',
              style: TextStyle(color: AppColors.onError),
            ),
          ),
        );
        return;
      }

      Get.snackbar(
        'Registration failed',
        _registrationErrorMessage(e),
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Registration failed',
        'Something went wrong. Please try again.',
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void _handleUnknownRegistrationOutcome() {
    Get.snackbar(
      'Registration status unknown',
      'The request may have been processed. Check your email for a verification code before trying again.',
      backgroundColor: AppColors.error,
      colorText: AppColors.onError,
      duration: const Duration(seconds: 7),
      snackPosition: SnackPosition.BOTTOM,
    );

    _openVerificationRecovery();
  }

  void _openVerificationRecovery() {
    Get.closeCurrentSnackbar();
    Get.toNamed(
      AppRoutes.otpVerification,
      arguments: {
        'email': emailController.text.trim(),
        'purpose': 'registration',
      },
    );
  }

  String _registrationErrorMessage(ApiException exception) {
    final messages = <String>[];
    final detail = exception.message.trim();
    if (detail.isNotEmpty && detail != 'Registration failed.') {
      messages.add(detail);
    }

    exception.fieldErrors?.forEach((field, fieldMessages) {
      for (final fieldMessage in fieldMessages) {
        final message = fieldMessage.trim();
        if (message.isEmpty ||
            messages.contains(message) ||
            detail.contains(message)) {
          continue;
        }
        messages.add('${_fieldLabel(field)}: $message');
      }
    });

    return messages.isEmpty
        ? 'Unable to create your account. Please check your details and try again.'
        : messages.join('\n');
  }

        bool _isExistingEmailError(ApiException exception) {
          final emailErrors = exception.fieldErrors?['email'] ?? const <String>[];
          final text = [exception.message, ...emailErrors].join(' ').toLowerCase();
          return text.contains('already exists') ||
          text.contains('already registered');
        }

  String _fieldLabel(String field) {
    switch (field) {
      case 'email':
        return 'Email';
      case 'password':
        return 'Password';
      case 'first_name':
        return 'First name';
      case 'last_name':
        return 'Last name';
      case 'phone_number':
        return 'Phone number';
      default:
        return field.replaceAll('_', ' ');
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
