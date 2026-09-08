import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/doctor/features/auth/controllers/patient_register_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PatientRegisterScreen extends GetView<PatientRegisterController> {
  const PatientRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Create Patient Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Join Gynae Hub',
                      style: AppTheme.headlineMedium.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your patient account to manage your health journey.',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    _field(controller.firstNameController, 'First name'),
                    _field(controller.lastNameController, 'Last name'),
                    _field(
                      controller.emailController,
                      'Email address',
                      keyboardType: TextInputType.emailAddress,
                      validator: controllerEmail,
                    ),
                    _field(
                      controller.phoneController,
                      'Phone number',
                      keyboardType: TextInputType.phone,
                      validator: controllerPhone,
                    ),
                    Obx(
                      () => _field(
                        controller.passwordController,
                        'Password',
                        obscureText: controller.obscurePassword.value,
                        validator: controllerPassword,
                        suffixIcon: IconButton(
                          onPressed: controller.togglePasswordVisibility,
                          icon: Icon(
                            controller.obscurePassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                    Obx(
                      () => _field(
                        controller.confirmPasswordController,
                        'Confirm password',
                        obscureText: controller.obscureConfirmPassword.value,
                        validator: (value) =>
                            value != controller.passwordController.text
                            ? 'Passwords do not match'
                            : null,
                        suffixIcon: IconButton(
                          onPressed: controller.toggleConfirmPasswordVisibility,
                          icon: Icon(
                            controller.obscureConfirmPassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : () => controller.submit(formKey),
                          child: controller.isSubmitting.value
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Create Account'),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.offNamed(AppRoutes.login),
                      child: const Text('Already have an account? Sign in'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController textController,
    String label, {
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: textController,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator ?? (value) => _required(value, label),
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  String? _required(String? value, String label) =>
      value == null || value.trim().isEmpty ? '$label is required' : null;

  String? controllerEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())
        ? null
        : 'Enter a valid email address';
  }

  String? controllerPhone(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Phone number is required';
    return RegExp(r'^\+?[0-9][0-9\s-]{7,19}$').hasMatch(value.trim())
        ? null
        : 'Enter a valid phone number';
  }

  String? controllerPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return RegExp(r'[A-Za-z]').hasMatch(value) && RegExp(r'\d').hasMatch(value)
        ? null
        : 'Use at least one letter and one number';
  }
}
