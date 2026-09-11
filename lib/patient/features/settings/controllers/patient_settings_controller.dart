import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/core/services/storage_service.dart';
import 'package:doctor/doctor/features/auth/controllers/auth_controller.dart';
import 'package:doctor/patient/features/settings/models/patient_profile_model.dart';
import 'package:doctor/patient/features/settings/repositories/patient_settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PatientSettingsController extends GetxController {
  final PatientSettingsRepository _repository = PatientSettingsRepository();
  final StorageService _storage = Get.find<StorageService>();

  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final profileData = Rx<PatientProfileData?>(null);

  final isDarkMode = false.obs;
  final areNotificationsEnabled = true.obs;
  final selectedLanguage = 'en_US'.obs;

  // Password validation
  final isLengthValid = false.obs;
  final hasUppercase = false.obs;
  final hasLowercase = false.obs;
  final hasSpecial = false.obs;

  // Change password error
  final changePasswordError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
    loadProfile();
  }

  void _loadPreferences() {
    final theme = _storage.getTheme();
    isDarkMode.value = theme == 'dark';

    final notifications = _storage.getNotifications();
    areNotificationsEnabled.value = notifications ?? true;

    final language = _storage.getLanguage();
    if (language != null && language != 'English' && language != 'Urdu') {
      selectedLanguage.value = language;
    } else if (language == 'Urdu') {
      selectedLanguage.value = 'ur_PK';
    }
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final data = await _repository.getPatientProfile();
      if (data != null) {
        profileData.value = data;
        debugPrint('[PATIENT_SETTINGS] Profile loaded successfully');
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to load profile. Please try again.';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'An error occurred. Please try again.';
      debugPrint('[PATIENT_SETTINGS] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProfile() async {
    await loadProfile();
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    isLoading.value = true;
    try {
      final updated = await _repository.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      if (updated != null) {
        final current = profileData.value;
        if (current != null) {
          profileData.value = current.copyWith(user: updated);
        }

        try {
          final authController = Get.find<AuthController>();
          if (authController.currentUser.value != null) {
            authController.currentUser.value = authController.currentUser.value!
                .copyWith(
                  firstName: updated.firstName,
                  lastName: updated.lastName,
                  phoneNumber: updated.phoneNumber,
                );
          }
        } catch (_) {}

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
      isLoading.value = false;
    }
  }

  Future<bool> updatePatientProfile({
    DateTime? dateOfBirth,
    DateTime? lmpDate,
    DateTime? eddDate,
    String? bloodGroup,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? address,
  }) async {
    isLoading.value = true;
    try {
      final updated = await _repository.updatePatientProfile(
        dateOfBirth: dateOfBirth,
        lmpDate: lmpDate,
        eddDate: eddDate,
        bloodGroup: bloodGroup,
        emergencyContactName: emergencyContactName,
        emergencyContactPhone: emergencyContactPhone,
        address: address,
      );

      if (updated != null) {
        final current = profileData.value;
        if (current != null) {
          profileData.value = current.copyWith(patientProfile: updated);
        }

        Get.snackbar(
          'Success',
          'Patient profile updated successfully!',
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
        'Failed to update patient profile. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    isLoading.value = true;
    changePasswordError.value = '';
    try {
      final errorMessage = await _repository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (errorMessage == null) {
        Get.snackbar(
          'Success',
          'Password changed successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        changePasswordError.value = errorMessage;
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.error,
          colorText: AppColors.onError,
        );
        return false;
      }
    } catch (e) {
      changePasswordError.value = 'An error occurred. Please try again.';
      Get.snackbar(
        'Error',
        'An error occurred. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void validatePasswordStrength(String password) {
    isLengthValid.value = password.length >= 8;
    hasUppercase.value = RegExp(r'[A-Z]').hasMatch(password);
    hasLowercase.value = RegExp(r'[a-z]').hasMatch(password);
    hasSpecial.value = RegExp(r'[^A-Za-z0-9]').hasMatch(password);
  }

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

  void setLanguage(String languageCode) {
    selectedLanguage.value = languageCode;
    _storage.setLanguage(languageCode);
    
    if (languageCode == 'ur_PK') {
      Get.updateLocale(const Locale('ur', 'PK'));
    } else {
      Get.updateLocale(const Locale('en', 'US'));
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
      try {
        Get.find<AuthController>().clearCurrentUser();
      } catch (_) {}
      Get.offAllNamed(AppRoutes.login);
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

  void showLanguageDialog() {
    final languages = [
      {'code': 'en_US', 'name': 'English'},
      {'code': 'ur_PK', 'name': 'اردو'},
    ];

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('settings.language'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            return Obx(() => RadioListTile<String>(
              title: Text(lang['name']!),
              value: lang['code']!,
              groupValue: selectedLanguage.value == 'English' ? 'en_US' : selectedLanguage.value, // Fallback for old storage
              onChanged: (value) {
                if (value != null) {
                  setLanguage(value);
                  Get.back();
                }
              },
            ));
          }).toList(),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('common.cancel'.tr)),
        ],
      ),
    );
  }

  void showAboutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('About'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gynae Hub',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(color: AppColors.surfaceContainer),
            const SizedBox(height: 8),
            Text(
              'A comprehensive pregnancy care platform for patients.',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  void showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  @override
  void onClose() {
    super.onClose();
  }
}
