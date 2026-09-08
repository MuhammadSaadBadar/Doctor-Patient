import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/doctor_avatar.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart'
    show MaterialSymbolIcon;
import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:doctor/patient/features/settings/controllers/patient_settings_controller.dart';
import 'package:doctor/patient/features/settings/models/patient_profile_model.dart';
import 'package:doctor/patient/features/settings/widgets/settings_section.dart';
import 'package:doctor/patient/features/settings/widgets/settings_tile.dart';
import 'package:doctor/patient/features/settings/widgets/settings_toggle_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PatientSettingsScreen extends GetView<PatientSettingsController> {
  const PatientSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          PatientTopAppBar(title: 'Settings', showBackButton: true),
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
                          _buildProfileSummaryCard(),
                          const SizedBox(height: 20),
                          _buildAccountSection(),
                          const SizedBox(height: 24),
                          _buildPatientProfileSection(),
                          const SizedBox(height: 24),
                          // _buildHealthSettingsSection(),
                          // const SizedBox(height: 24),
                          _buildAppPreferencesSection(),
                          const SizedBox(height: 24),
                          // _buildSupportSection(),
                          // const SizedBox(height: 24),
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
    );
  }

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

  Widget _buildProfileSummaryCard() {
    return Obx(() {
      final profile = controller.profileData.value;
      if (profile == null) return const SizedBox.shrink();

      return GestureDetector(
        onTap: () => Get.toNamed('/patient/profile/edit')?.then((result) {
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
              DoctorAvatar(
                imageUrl: profile.user.profilePictureUrl,
                firstName: profile.user.firstName,
                lastName: profile.user.lastName,
                size: 56,
                enableCacheBusting: true,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.user.fullName,
                      style: AppTheme.headlineSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.user.email,
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
                        'Patient',
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

  Widget _buildAccountSection() {
    return Obx(() {
      final profile = controller.profileData.value;

      return SettingsSection(
        title: 'Account & Profile',
        children: [
          SettingsTile(
            icon: 'person',
            title: 'Edit Personal Info',
            subtitle: 'Name, email, phone number',
            onTap: () => Get.toNamed('/patient/profile/edit')?.then((result) {
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
            onTap: controller.showChangePasswordDialog,
          ),
          SettingsTile(
            icon: 'medical_services',
            title: 'Patient Profile',
            subtitle: 'Pregnancy, emergency contact, medical info',
            onTap: () => Get.toNamed('/patient/profile/edit')?.then((result) {
              if (result == true) {
                controller.refreshProfile();
              }
            }),
            isLast: true,
          ),
        ],
      );
    });
  }

  Widget _buildPatientProfileSection() {
    return Obx(() {
      final patientProfile = controller.profileData.value?.patientProfile;

      return SettingsSection(
        title: 'Patient Profile',
        children: [
          SettingsTile(
            icon: 'calendar_today',
            title: 'Date of Birth',
            subtitle: patientProfile?.dateOfBirth != null
                ? '${patientProfile!.dateOfBirth!.day}/${patientProfile.dateOfBirth!.month}/${patientProfile.dateOfBirth!.year}'
                : 'Not set',
            onTap: () => _showDateOfBirthDialog(),
            isFirst: true,
          ),
          SettingsTile(
            icon: 'pregnant_woman',
            title: 'Pregnancy Dates',
            subtitle: _buildPregnancySubtitle(patientProfile),
            onTap: () => _showPregnancyDatesDialog(),
          ),
          SettingsTile(
            icon: 'bloodtype',
            title: 'Blood Group',
            subtitle: patientProfile?.bloodGroupDisplay ?? 'Not set',
            onTap: () => _showBloodGroupDialog(),
          ),
          SettingsTile(
            icon: 'contact_emergency',
            title: 'Emergency Contact',
            subtitle: patientProfile?.emergencyContactDisplay ?? 'Not set',
            onTap: () => _showEmergencyContactDialog(),
          ),
          SettingsTile(
            icon: 'location_on',
            title: 'Address',
            subtitle: patientProfile?.addressDisplay ?? 'Not set',
            onTap: () => _showAddressDialog(),
            isLast: true,
          ),
        ],
      );
    });
  }

  String _buildPregnancySubtitle(PatientProfile? profile) {
    if (profile == null) return 'Not set';
    final parts = <String>[];
    if (profile.lmpDate != null) {
      parts.add('LMP: ${profile.formattedLmpDate}');
    }
    if (profile.eddDate != null) {
      parts.add('EDD: ${profile.formattedEddDate}');
    }
    if (profile.pregnancyWeek != null) {
      parts.add(profile.pregnancyWeek!);
    }
    return parts.isEmpty ? 'Not set' : parts.join(' • ');
  }

  Widget _buildHealthSettingsSection() {
    return SettingsSection(
      title: 'Health Settings',
      children: [
        SettingsToggleTile(
          icon: 'notifications_active',
          title: 'Vitals Reminders',
          subtitle: 'Get reminded to log blood pressure & sugar',
          value: controller.areNotificationsEnabled.value,
          onChanged: controller.toggleNotifications,
          isFirst: true,
        ),
        SettingsToggleTile(
          icon: 'water_drop',
          title: 'Water Intake Reminders',
          subtitle: 'Stay hydrated throughout the day',
          value: true,
          onChanged: (value) {},
        ),
        SettingsToggleTile(
          icon: 'favorite',
          title: 'Kick Count Reminders',
          subtitle: 'Daily reminders for fetal movement tracking',
          value: true,
          onChanged: (value) {},
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildAppPreferencesSection() {
    return SettingsSection(
      title: 'App Preferences',
      children: [
        SettingsToggleTile(
          icon: 'dark_mode',
          title: 'Dark Mode',
          value: controller.isDarkMode.value,
          onChanged: controller.toggleTheme,
          isFirst: true,
        ),
        SettingsToggleTile(
          icon: 'notifications_active',
          title: 'Push Notifications',
          subtitle: 'Receive appointment and health reminders',
          value: controller.areNotificationsEnabled.value,
          onChanged: controller.toggleNotifications,
        ),
        SettingsTile(
          icon: 'language',
          title: 'Language',
          subtitle: controller.selectedLanguage.value,
          onTap: controller.showLanguageDialog,
          isLast: true,
        ),
      ],
    );
  }

  // Widget _buildSupportSection() {
  //   return SettingsSection(
  //     title: 'Support & Legal',
  //     children: [
  //       SettingsTile(
  //         icon: 'help_outline',
  //         title: 'Help Center',
  //         onTap: () {
  //           Get.snackbar(
  //             'Coming Soon',
  //             'Help center will be available soon',
  //             snackPosition: SnackPosition.TOP,
  //           );
  //         },
  //         isFirst: true,
  //       ),
  //       SettingsTile(
  //         icon: 'privacy_tip',
  //         title: 'Privacy Policy',
  //         onTap: () {
  //           Get.snackbar(
  //             'Coming Soon',
  //             'Privacy policy will be available soon',
  //             snackPosition: SnackPosition.TOP,
  //           );
  //         },
  //       ),
  //       SettingsTile(
  //         icon: 'gavel',
  //         title: 'Terms & Conditions',
  //         onTap: () {
  //           Get.snackbar(
  //             'Coming Soon',
  //             'Terms & conditions will be available soon',
  //             snackPosition: SnackPosition.TOP,
  //           );
  //         },
  //       ),
  //       SettingsTile(
  //         icon: 'info',
  //         title: 'About',
  //         subtitle: 'Version 1.0.0',
  //         onTap: controller.showAboutDialog,
  //         isLast: true,
  //       ),
  //     ],
  //   );
  // }

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
        onTap: controller.showLogoutDialog,
        isOnly: true,
      ),
    );
  }

  void _showDateOfBirthDialog() {
    final profile = controller.profileData.value?.patientProfile;
    DateTime? selectedDate = profile?.dateOfBirth;
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 100);
    final lastDate = now;

    showDatePicker(
      context: Get.context!,
      initialDate: selectedDate ?? DateTime(now.year - 25),
      firstDate: firstDate,
      lastDate: lastDate,
    ).then((picked) {
      if (picked != null && picked != selectedDate) {
        controller.updatePatientProfile(dateOfBirth: picked);
      }
    });
  }

  void _showPregnancyDatesDialog() {
    final profile = controller.profileData.value?.patientProfile;
    final lmpController = TextEditingController(
      text: profile?.lmpDate != null
          ? '${profile!.lmpDate!.day}/${profile.lmpDate!.month}/${profile.lmpDate!.year}'
          : '',
    );
    final eddController = TextEditingController(
      text: profile?.eddDate != null
          ? '${profile!.eddDate!.day}/${profile.eddDate!.month}/${profile.eddDate!.year}'
          : '',
    );

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Pregnancy Dates'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: lmpController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'LMP Date (Last Menstrual Period)',
                hintText: 'DD/MM/YYYY',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: Get.context!,
                  initialDate: profile?.lmpDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 300)),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  lmpController.text =
                      '${picked.day}/${picked.month}/${picked.year}';
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: eddController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'EDD Date (Expected Due Date)',
                hintText: 'DD/MM/YYYY',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: Get.context!,
                  initialDate:
                      profile?.eddDate ??
                      DateTime.now().add(const Duration(days: 280)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 300)),
                );
                if (picked != null) {
                  eddController.text =
                      '${picked.day}/${picked.month}/${picked.year}';
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              DateTime? lmpDate;
              DateTime? eddDate;

              if (lmpController.text.isNotEmpty) {
                final parts = lmpController.text.split('/');
                if (parts.length == 3) {
                  lmpDate = DateTime(
                    int.parse(parts[2]),
                    int.parse(parts[1]),
                    int.parse(parts[0]),
                  );
                }
              }
              if (eddController.text.isNotEmpty) {
                final parts = eddController.text.split('/');
                if (parts.length == 3) {
                  eddDate = DateTime(
                    int.parse(parts[2]),
                    int.parse(parts[1]),
                    int.parse(parts[0]),
                  );
                }
              }

              Get.back();
              controller.updatePatientProfile(
                lmpDate: lmpDate,
                eddDate: eddDate,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showBloodGroupDialog() {
    final profile = controller.profileData.value?.patientProfile;
    final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Blood Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: bloodGroups.map((group) {
            return RadioListTile<String>(
              title: Text(group),
              value: group,
              groupValue: profile?.bloodGroup,
              onChanged: (value) {
                if (value != null) {
                  controller.updatePatientProfile(bloodGroup: value);
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

  void _showEmergencyContactDialog() {
    final profile = controller.profileData.value?.patientProfile;
    final nameController = TextEditingController(
      text: profile?.emergencyContactName ?? '',
    );
    final phoneController = TextEditingController(
      text: profile?.emergencyContactPhone ?? '',
    );

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Emergency Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Contact Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.updatePatientProfile(
                emergencyContactName: nameController.text.trim().isEmpty
                    ? null
                    : nameController.text.trim(),
                emergencyContactPhone: phoneController.text.trim().isEmpty
                    ? null
                    : phoneController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddressDialog() {
    final profile = controller.profileData.value?.patientProfile;
    final controller_ = TextEditingController(text: profile?.address ?? '');

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Address'),
        content: TextField(
          controller: controller_,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Address',
            hintText: 'Enter your address',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.updatePatientProfile(
                address: controller_.text.trim().isEmpty
                    ? null
                    : controller_.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
