// lib/features/profile/controllers/profile_controller.dart

import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/features/settings/models/doctor_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor/core/services/storage_service.dart';
import 'package:doctor/features/profile/repositories/profile_repository.dart';
import 'package:doctor/features/profile/models/profile_models.dart';
import 'package:doctor/features/profile/models/add_payment_method.dart';
import 'package:doctor/features/settings/models/payment_method_model.dart';

class ProfileController extends GetxController {
  final ProfileRepository _repository = Get.find<ProfileRepository>();
  final StorageService _storage = Get.find<StorageService>();

  // State
  final isLoading = false.obs;
  final isSaving = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Data
  final profileData = Rx<ProfileData?>(null);
  final dashboardStats = Rx<DoctorDashboardStats?>(null);
  final paymentMethods = Rx<PlatformPaymentMethod?>(null);

  // ============ MY PAYMENT METHOD ============
  final myPaymentMethod = Rx<PaymentMethodDetails?>(null);

  final isAcceptingPatients = true.obs;

  // App Preferences (local only)
  final isDarkMode = false.obs;
  final areNotificationsEnabled = true.obs;
  final selectedLanguage = 'English'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
    loadProfile();
    // Set initial value from profile data
    ever(profileData, (data) {
      if (data?.doctorProfile != null) {
        isAcceptingPatients.value = data!.doctorProfile!.isAcceptingPatients;
        // Also update myPaymentMethod from profile data
        _updateMyPaymentMethod(data?.doctorProfile);
      }
    });
  }

  void _loadPreferences() {
    final theme = _storage.getTheme();
    isDarkMode.value = theme == 'dark';

    final notifications = _storage.getNotifications();
    areNotificationsEnabled.value = notifications ?? true;

    final language = _storage.getLanguage();
    if (language != null) {
      selectedLanguage.value = language;
    }
  }

  /// Update myPaymentMethod from doctor profile
  void _updateMyPaymentMethod(DoctorProfile? doctorProfile) {
    if (doctorProfile == null) {
      myPaymentMethod.value = null;
      return;
    }

    // Extract payment method details from doctor profile
    final method = PaymentMethodDetails(
      method: _parsePayoutMethod(doctorProfile.payoutMethod),
      jazzcashNumber: doctorProfile.payoutJazzcashNumber,
      jazzcashAccountTitle: doctorProfile.payoutJazzcashAccountTitle,
      easypaisaNumber: doctorProfile.payoutEasypaisaNumber,
      easypaisaAccountTitle: doctorProfile.payoutEasypaisaAccountTitle,
      bankName: doctorProfile.payoutBankName,
      bankAccountTitle: doctorProfile.payoutBankAccountTitle,
      bankAccountNumber: doctorProfile.payoutBankAccountNumber,
      bankIban: doctorProfile.payoutBankIban,
    );

    myPaymentMethod.value = method;
  }

  /// Parse payout method string to enum
  PayoutMethod? _parsePayoutMethod(String? value) {
    if (value == null || value.isEmpty) return null;
    switch (value.toLowerCase()) {
      case 'jazzcash':
        return PayoutMethod.jazzcash;
      case 'easypaisa':
        return PayoutMethod.easypaisa;
      case 'bank':
        return PayoutMethod.bank;
      default:
        return null;
    }
  }

  /// Load all profile data
  Future<void> loadProfile() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      // Load user profile
      final userProfile = await _repository.getUserProfile();
      if (userProfile != null) {
        profileData.value = userProfile;
        // Update myPaymentMethod from the loaded profile
        _updateMyPaymentMethod(userProfile.doctorProfile);
      }

      // Load dashboard stats
      final stats = await _repository.getDoctorDashboardStats();
      if (stats != null) {
        dashboardStats.value = stats;
      }

      // Load platform payment methods
      final methods = await _repository.getPaymentMethods();
      if (methods != null) {
        paymentMethods.value = methods;
      }

      debugPrint('[PROFILE] Profile loaded successfully');
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load profile. Please try again.';
      debugPrint('[PROFILE] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh profile data
  Future<void> refreshProfile() async {
    await loadProfile();
  }

  /// Load payment methods separately (for settings screen)
  Future<void> loadPaymentMethods() async {
    try {
      final methods = await _repository.getPaymentMethods();
      if (methods != null) {
        paymentMethods.value = methods;
      }
    } catch (e) {
      debugPrint('[PROFILE] Failed to load payment methods: $e');
    }
  }

  /// Refresh payment methods
  Future<void> refreshPaymentMethods() async {
    await loadPaymentMethods();
    // Also refresh myPaymentMethod in case it was updated
    await loadMyPaymentMethod();
  }

  /// Load only the doctor's own payment method
  Future<void> loadMyPaymentMethod() async {
    try {
      final userProfile = await _repository.getUserProfile();
      if (userProfile != null) {
        _updateMyPaymentMethod(userProfile.doctorProfile);
        // Also update profileData if needed
        if (profileData.value == null) {
          profileData.value = userProfile;
        }
      }
      debugPrint('[PROFILE] My payment method loaded');
    } catch (e) {
      debugPrint('[PROFILE] Failed to load my payment method: $e');
    }
  }

  /// Update doctor's payment method (called after saving)
  Future<void> refreshMyPaymentMethod() async {
    await loadMyPaymentMethod();
  }

  /// Update user profile
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    isSaving.value = true;
    try {
      final updated = await _repository.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      if (updated != null) {
        profileData.value = updated;
        _updateMyPaymentMethod(updated.doctorProfile);
        Get.snackbar(
          'Success',
          'Profile updated successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to update profile. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.error,
          colorText: AppColors.onError,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Update doctor profile
  Future<bool> updateDoctorProfile({
    String? specialization,
    String? licenseNumber,
    int? yearsOfExperience,
    String? bio,
    bool? isAcceptingPatients,
    String? city,
    String? area,
    String? latitude,
    String? longitude,
    String? consultationFee,
  }) async {
    isSaving.value = true;
    try {
      final updated = await _repository.updateDoctorProfile(
        specialization: specialization,
        licenseNumber: licenseNumber,
        yearsOfExperience: yearsOfExperience,
        bio: bio,
        isAcceptingPatients: isAcceptingPatients,
        city: city,
        area: area,
        latitude: latitude,
        longitude: longitude,
        consultationFee: consultationFee,
      );

      if (updated != null) {
        // Update the doctor profile in the main profile data
        final current = profileData.value;
        if (current != null) {
          profileData.value = current.copyWith(doctorProfile: updated);
        }
        // Update myPaymentMethod
        _updateMyPaymentMethod(updated);
        if (isAcceptingPatients != null) {
          this.isAcceptingPatients.value = isAcceptingPatients;
        }
        Get.snackbar(
          'Success',
          'Doctor profile updated successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to update doctor profile. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.error,
          colorText: AppColors.onError,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Update only consultation fee
  Future<bool> updateConsultationFee(String fee) async {
    isSaving.value = true;
    try {
      final updated = await _repository.updateDoctorProfile(
        consultationFee: fee.isEmpty ? null : fee,
      );

      if (updated != null) {
        final current = profileData.value;
        if (current != null) {
          profileData.value = current.copyWith(doctorProfile: updated);
        }
        _updateMyPaymentMethod(updated);
        Get.snackbar(
          'Success',
          'Consultation fee updated successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update consultation fee.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Toggle accepting patients
  Future<bool> toggleAcceptingPatients(bool value) async {
    isSaving.value = true;
    try {
      final updated = await _repository.updateDoctorProfile(
        isAcceptingPatients: value,
      );

      if (updated != null) {
        final current = profileData.value;
        if (current != null) {
          profileData.value = current.copyWith(doctorProfile: updated);
        }
        _updateMyPaymentMethod(updated);
        isAcceptingPatients.value = value;
        Get.snackbar(
          'Success',
          value
              ? 'Now accepting new patients'
              : 'No longer accepting new patients',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update practice status.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    isSaving.value = true;
    try {
      final success = await _repository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (success) {
        Get.snackbar(
          'Success',
          'Password changed successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to change password. Please check your old password.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.error,
          colorText: AppColors.onError,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ==================== THEME ====================
  void toggleTheme(bool value) {
    isDarkMode.value = value;
    _storage.setTheme(value ? 'dark' : 'light');
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);

    Get.snackbar(
      'Theme Updated',
      value ? 'Dark mode enabled' : 'Light mode enabled',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  // ==================== NOTIFICATIONS ====================
  void toggleNotifications(bool value) {
    areNotificationsEnabled.value = value;
    _storage.setNotifications(value);

    Get.snackbar(
      'Notifications',
      value ? 'Notifications enabled' : 'Notifications disabled',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  // ==================== LANGUAGE ====================
  void setLanguage(String language) {
    selectedLanguage.value = language;
    _storage.setLanguage(language);
    // TODO: Update app locale
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _repository.logout();
      await _storage.clearAll();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
