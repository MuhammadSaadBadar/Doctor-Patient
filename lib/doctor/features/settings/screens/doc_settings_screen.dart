import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/bottom_nav_bar.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';
import 'package:doctor/core/widgets/top_app_bar.dart';
import 'package:doctor/doctor/features/profile/controllers/doc_edit_profile_controller.dart';
import 'package:doctor/doctor/features/profile/controllers/doc_profile_controller.dart';
import 'package:doctor/doctor/features/settings/widgets/settings_section.dart';
import 'package:doctor/doctor/features/settings/widgets/settings_tile.dart';
import 'package:doctor/doctor/features/settings/widgets/settings_toggle_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorSettingsScreen extends GetView<DoctorProfileController> {
  const DoctorSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          const TopAppNavBar.gradient(
            title: 'Settings',
            height: 64,
            showBackButton: true,
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState();
              }

              if (controller.hasError.value) {
                return _buildErrorState();
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: controller.refreshProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        children: [
                          // Profile Summary Card
                          _buildProfileSummaryCard(),
                          const SizedBox(height: 20),

                          // Account & Profile
                          _buildAccountSection(),
                          const SizedBox(height: 24),

                          // Practice Settings
                          _buildDoctorProfileSection(),
                          const SizedBox(height: 24),

                          // Payment Methods
                          _buildPaymentSection(),
                          const SizedBox(height: 24),

                          // App Preferences
                          _buildAppPreferencesSection(),
                          const SizedBox(height: 24),

                          // Support & Legal
                          // _buildSupportSection(),
                          // const SizedBox(height: 24),

                          // Logout
                          _buildLogoutButton(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  // ==================== LOADING STATE ====================
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text('Loading settings...'),
        ],
      ),
    );
  }

  // ==================== ERROR STATE ====================
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage.value,
              style: AppTheme.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: controller.refreshProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== PROFILE SUMMARY CARD ====================
  Widget _buildProfileSummaryCard() {
    return Obx(() {
      final profile = controller.profileData.value;
      if (profile == null) return const SizedBox.shrink();

      return GestureDetector(
        onTap: () => Get.toNamed('/edit-profile')?.then((result) {
          if (result == true) {
            controller.refreshProfile();
          }
        }),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    profile.initials,
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppColors.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. ${profile.fullName}',
                      style: AppTheme.headlineSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.email,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        'Doctor',
                        style: AppTheme.labelMedium.copyWith(
                          color: AppColors.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              MaterialSymbolIcon(
                'chevron_right',
                size: 24,
                color: AppColors.outline,
              ),
            ],
          ),
        ),
      );
    });
  }

  // ==================== ACCOUNT SECTION ====================
  Widget _buildAccountSection() {
    return SettingsSection(
      title: 'Account & Profile',
      children: [
        SettingsTile(
          icon: 'person',
          title: 'Edit Personal Info',
          subtitle: 'Name, email, phone number',
          onTap: () => Get.toNamed('/edit-profile')?.then((result) {
            if (result == true) {
              controller.refreshProfile();
            }
          }),
          isFirst: true,
        ),
        SettingsTile(
          icon: 'lock_outline',
          title: 'Change Password',
          subtitle: 'Update your password',
          onTap: () => Get.toNamed('/change-password'),
        ),
        SettingsTile(
          icon: 'medical_services',
          title: 'Doctor Profile',
          subtitle: 'Specialization, license, bio',
          onTap: () => Get.toNamed('/profile'),
          isLast: true,
        ),
      ],
    );
  }

  // ==================== DOCTOR PROFILE SECTION ====================
  Widget _buildDoctorProfileSection() {
    return Obx(() {
      final doctorProfile = controller.profileData.value?.doctorProfile;

      return SettingsSection(
        title: 'Practice Settings',
        children: [
          SettingsTile(
            icon: 'payments',
            title: 'Consultation Fee',
            subtitle: doctorProfile?.consultationFeeDisplay ?? 'Not set',
            onTap: () => _showConsultationFeeDialog(),
            isFirst: true,
          ),
          SettingsToggleTile(
            icon: 'group_add',
            title: 'Accepting New Patients',
            subtitle: doctorProfile?.isAcceptingPatients == true
                ? 'Currently accepting new patients'
                : 'Not accepting new patients',
            value: controller.isAcceptingPatients.value,
            onChanged: (value) => controller.toggleAcceptingPatients(value),
          ),
          SettingsTile(
            icon: 'location_on',
            title: 'Practice Location',
            subtitle: doctorProfile?.locationDisplay ?? 'Not set',
            onTap: () => Get.toNamed('/profile'),
            isLast: true,
          ),
        ],
      );
    });
  }

  // ==================== PAYMENT SECTION ====================
  Widget _buildPaymentSection() {
    return SettingsSection(
      title: 'Payments',
      children: [
        SettingsTile(
          icon: 'payments',
          title: 'Payment Methods',
          subtitle: 'View platform payment details',
          onTap: () => Get.toNamed('/payment-methods'),
          isFirst: true,
          isLast: true,
        ),
      ],
    );
  }

  // ==================== APP PREFERENCES SECTION ====================
  Widget _buildAppPreferencesSection() {
    return SettingsSection(
      title: 'App Preferences',
      children: [
        // SettingsTile(
        //   icon: 'language',
        //   title: 'Language',
        //   subtitle: controller.selectedLanguage.value,
        //   onTap: _showLanguageDialog,
        //   isFirst: true,
        // ),
        SettingsToggleTile(
          icon: 'dark_mode',
          title: 'Dark Mode',
          value: controller.isDarkMode.value,
          onChanged: controller.toggleTheme,
        ),
        SettingsToggleTile(
          icon: 'notifications_active',
          title: 'Push Notifications',
          subtitle: 'Receive appointment and message notifications',
          value: controller.areNotificationsEnabled.value,
          onChanged: controller.toggleNotifications,
          isLast: true,
        ),
      ],
    );
  }

  // ==================== SUPPORT SECTION ====================
  // Widget _buildSupportSection() {
  //   return SettingsSection(
  //     title: 'Support & Legal',
  //     children: [
  //       SettingsTile(
  //         icon: 'help_outline',
  //         title: 'Help Center',
  //         onTap: () {
  //           // TODO: Open help center
  //         },
  //         isFirst: true,
  //       ),
  //       SettingsTile(
  //         icon: 'privacy_tip',
  //         title: 'Privacy Policy',
  //         onTap: () {
  //           // TODO: Open privacy policy
  //         },
  //       ),
  //       SettingsTile(
  //         icon: 'gavel',
  //         title: 'Terms & Conditions',
  //         onTap: () {
  //           // TODO: Open terms
  //         },
  //       ),
  //       SettingsTile(
  //         icon: 'info',
  //         title: 'About',
  //         subtitle: 'Version 1.0.0',
  //         onTap: _showAboutDialog,
  //         isLast: true,
  //       ),
  //     ],
  //   );
  // }

  // ==================== LOGOUT BUTTON ====================
  Widget _buildLogoutButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: SettingsTile(
        icon: 'logout',
        title: 'Logout',
        textColor: AppColors.error,
        iconColor: AppColors.error,
        onTap: _showLogoutDialog,
        isOnly: true,
      ),
    );
  }

  // ==================== DIALOGS ====================

  void _showConsultationFeeDialog() {
    final currentFee =
        controller.profileData.value?.doctorProfile?.consultationFee ?? '';
    final feeController = TextEditingController(text: currentFee);
    final feeError = ''.obs;

    Get.dialog(
      Obx(
        () => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Consultation Fee'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: feeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Fee (PKR)',
                  hintText: 'Enter consultation fee',
                  prefixText: 'Rs. ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorText: feeError.value.isNotEmpty ? feeError.value : null,
                  errorStyle: const TextStyle(fontSize: 12),
                ),
                onChanged: (value) {
                  if (value.trim().isNotEmpty) {
                    final fee = double.tryParse(value.trim());
                    if (fee == null || fee < 0) {
                      feeError.value = 'Please enter a valid amount';
                    } else {
                      feeError.value = '';
                    }
                  } else {
                    feeError.value = '';
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final feeText = feeController.text.trim();
                if (feeText.isEmpty) {
                  feeError.value = 'Consultation fee is required';
                  return;
                }
                final fee = double.tryParse(feeText);
                if (fee == null || fee < 0) {
                  feeError.value = 'Please enter a valid amount';
                  return;
                }

                Get.back();
                final success = await controller.updateConsultationFee(feeText);
                if (success) {
                  // Force EditProfileController to reload on next visit
                  Get.delete<DoctorEditProfileController>();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    const languages = ['English', 'Urdu', 'Arabic'];

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((language) {
            return RadioListTile<String>(
              title: Text(language),
              value: language,
              groupValue: controller.selectedLanguage.value,
              onChanged: (value) {
                if (value != null) {
                  controller.setLanguage(value);
                  Get.back();
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ],
      ),
    );
  }

  void _showAboutDialog() {
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
              style: AppTheme.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(color: AppColors.surfaceContainer),
            const SizedBox(height: 8),
            Text(
              'A comprehensive pregnancy care platform for healthcare providers.',
              style: AppTheme.bodyMedium.copyWith(color: AppColors.onSurface),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
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
              controller.logout();
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
}
