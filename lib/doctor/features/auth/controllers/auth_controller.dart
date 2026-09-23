import 'dart:async';

import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/constants/user_role.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/network/api_exceptions.dart';
import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/core/services/storage_service.dart';
import 'package:doctor/doctor/features/auth/repositories/auth_repository.dart';
import 'package:doctor/doctor/features/profile/models/doc_edit_profile_model.dart';
import 'package:doctor/doctor/features/profile/repositories/doc_edit_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Global user model for reactive profile state across the app
class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final bool isEmailVerified;
  final String role;
  final DateTime dateJoined;
  final String? profilePictureUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.isEmailVerified,
    required this.role,
    required this.dateJoined,
    this.profilePictureUrl,
  });

  factory UserModel.fromDoctorProfileResponse(DoctorProfileResponse response) {
    return UserModel(
      id: response.id,
      email: response.email,
      firstName: response.firstName,
      lastName: response.lastName,
      phoneNumber: response.phoneNumber,
      isEmailVerified: response.isEmailVerified,
      role: response.role,
      dateJoined: response.dateJoined,
      profilePictureUrl: response.doctorProfile?.profilePictureUrl,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    bool? isEmailVerified,
    String? role,
    DateTime? dateJoined,
    String? profilePictureUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      role: role ?? this.role,
      dateJoined: dateJoined ?? this.dateJoined,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }

  String get fullName => '$firstName $lastName';

  String get initials {
    if (firstName.isEmpty || lastName.isEmpty) return 'DR';
    return '${firstName[0]}${lastName[0]}'.toUpperCase();
  }
}

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

  // Global reactive user profile state
  final currentUser = Rx<UserModel?>(null);

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
      final result = await _repository.login(
        email,
        password,
        preferredRole: preferredRole,
      );
      if (result.success && result.role != null) {
        // TODO: Get FCM token from Firebase Messaging when package is added
        // final fcmToken = await FirebaseMessaging.instance.getToken();
        // if (fcmToken != null) await updateFcmToken(fcmToken);

        // Fetch and populate global user profile
        await initializeCurrentUser();

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
      final error = await _repository.resetPassword(email);
      if (error == null) {
        startOtpTimer();
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
          error,
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.error,
          colorText: AppColors.onError,
        );
      }
    } on NetworkException {
      Get.toNamed(
        AppRoutes.otpVerification,
        arguments: {'email': email, 'purpose': 'reset'},
      );
      Get.snackbar(
        'Reset request status unknown',
        'The request may have been processed. Check your email for a code before trying again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
        duration: const Duration(seconds: 7),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============ OTP Methods ============
  Future<void> verifyOtp(String otp, String email) async {
    isOtpLoading.value = true;
    try {
      final purpose = Get.arguments?['purpose'] as String? ?? 'reset';
      if (purpose == 'registration') {
        final error = await _repository.verifyEmail(email, otp);
        if (error == null) {
          _timer?.cancel();
          clearOtpFields();
          Get.offAllNamed(AppRoutes.login);
          Get.snackbar(
            'Email verified',
            'Your account is ready. You can now sign in.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.secondary,
            colorText: AppColors.onPrimary,
          );
        } else {
          Get.snackbar(
            'Verification Failed',
            error,
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.error,
            colorText: AppColors.onError,
          );
        }
        return;
      }

      final error = await _repository.verifyOtpForReset(email, otp);
      if (error == null) {
        resetToken.value = _repository.getResetToken ?? '';
        _timer?.cancel();
        clearOtpFields();
        Get.toNamed(AppRoutes.resetPassword);
      } else {
        Get.snackbar(
          'Verification Failed',
          error,
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
      final purpose = Get.arguments?['purpose'] as String? ?? 'reset';
      final error = purpose == 'registration'
          ? await _repository.resendVerification(email)
          : await _repository.resendResetOtp(email);
      if (error == null) {
        startOtpTimer();
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
          error,
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
  void clearOtpFields() {
    for (var controller in otpControllers) {
      controller.clear();
    }
  }

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
      final error = await _repository.resetPasswordWithToken(
        token,
        newPassword,
      );
      if (error == null) {
        resetToken.value = '';
        Get.offAllNamed(AppRoutes.passwordResetSuccess);
      } else {
        Get.snackbar(
          'Error',
          error,
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
      final error = await _repository.changePassword(oldPassword, newPassword);
      if (error == null) {
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
          error,
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
  void startOtpTimer() {
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

  /// Populates [currentUser] from the appropriate backend endpoint.
  ///
  /// Must be called with an authoritative [role] so that patient data is never
  /// loaded through the Doctor-specific repository (which would cause cross-role
  /// state contamination — i.e. Patient name appearing in Doctor profile screens).
  ///
  /// When [role] is omitted, the stored role is used as a fallback.
  Future<void> initializeCurrentUser({String? role}) async {
    final effectiveRole = role ?? StorageService.instance.userRole ?? '';
    try {
      if (effectiveRole == 'doctor') {
        // Doctor: use the Doctor profile repository which also fetches doctor_profile.
        final profileRepo = DoctorEditProfileRepository();
        final profile = await profileRepo.getProfile();
        if (profile != null) {
          currentUser.value = UserModel.fromDoctorProfileResponse(profile);
          debugPrint(
            '[AUTH] Doctor user initialized: ${currentUser.value?.fullName}',
          );
        }
      } else {
        // Patient (or any non-doctor role): call /api/v1/auth/me/ directly and
        // build a minimal UserModel without the Doctor-specific profile data.
        final apiClient = Get.find<ApiClient>();
        final response = await apiClient.get(ApiConstants.authMe);
        if (response.statusCode == 200) {
          final data = response.data as Map<String, dynamic>;
          currentUser.value = UserModel(
            id: (data['id'] ?? '').toString(),
            email: (data['email'] as String?) ?? '',
            firstName: (data['first_name'] as String?) ?? '',
            lastName: (data['last_name'] as String?) ?? '',
            phoneNumber: (data['phone_number'] as String?) ?? '',
            isEmailVerified: (data['is_email_verified'] as bool?) ?? false,
            role: (data['role'] as String?) ?? effectiveRole,
            dateJoined: DateTime.tryParse(
                  (data['date_joined'] as String?) ?? '',
                ) ??
                DateTime.now(),
            profilePictureUrl: null,
          );
          debugPrint(
            '[AUTH] Patient user initialized: ${currentUser.value?.fullName}',
          );
        }
      }
    } catch (e) {
      debugPrint('[AUTH] Failed to initialize current user: $e');
    }
  }

  /// Update profile picture URL globally with cache-busting timestamp
  void updateProfileImage(String newUrl) {
    if (currentUser.value != null) {
      // Append timestamp for cache busting
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final cacheBustedUrl = '$newUrl?v=$timestamp';
      currentUser.value = currentUser.value!.copyWith(
        profilePictureUrl: cacheBustedUrl,
      );
      debugPrint('[AUTH] Profile image updated globally: $cacheBustedUrl');
    }
  }

  /// Clear current user on logout
  void clearCurrentUser() {
    currentUser.value = null;
  }

  /// Clear profile image globally (after deletion)
  void clearProfileImage() {
    if (currentUser.value != null) {
      final user = currentUser.value!;
      currentUser.value = UserModel(
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        phoneNumber: user.phoneNumber,
        isEmailVerified: user.isEmailVerified,
        role: user.role,
        dateJoined: user.dateJoined,
        profilePictureUrl: null,
      );
      debugPrint('[AUTH] Profile image cleared globally');
    }
  }
}
