// lib/patient/features/settings/screens/patient_settings_screen.dart

import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/utils/date_picker_helper.dart';
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
import 'package:doctor/core/localization/translation_keys.dart';

class PatientSettingsScreen extends GetView<PatientSettingsController> {
  const PatientSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          PatientTopAppBar(
            title: TranslationKeys.settingsTitle.tr,
            showBackButton: true,
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState(context);
              }

              if (controller.hasError.value) {
                return _buildErrorState();
              }

              return RefreshIndicator(
                color: Theme.of(context).colorScheme.primary,
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
                          _buildProfileSummaryCard(context),
                          const SizedBox(height: 20),
                          _buildAccountSection(),
                          const SizedBox(height: 24),
                          _buildPatientProfileSection(context),
                          const SizedBox(height: 24),
                          // _buildHealthSettingsSection(),
                          // const SizedBox(height: 24),
                          _buildAppPreferencesSection(),
                          const SizedBox(height: 24),
                          // _buildSupportSection(),
                          // const SizedBox(height: 24),
                          _buildLogoutButton(context),
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

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(TranslationKeys.settingsLoading.tr),
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
                child: Text(TranslationKeys.commonRetry.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSummaryCard(BuildContext context) {
    return Obx(() {
      final profile = controller.profileData.value;
      if (profile == null) return const SizedBox.shrink();

      final isDark = Theme.of(context).brightness == Brightness.dark;
      final colorScheme = Theme.of(context).colorScheme;

      return GestureDetector(
        onTap: () => Get.toNamed('/patient/profile/edit')?.then((result) {
          if (result == true) {
            controller.refreshProfile();
          }
        }),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    colors: [
                      colorScheme.primary.withOpacity(0.10),
                      colorScheme.primaryContainer.withOpacity(0.06),
                    ],
                  )
                : null,
            color: !isDark ? colorScheme.surfaceContainerLowest : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? colorScheme.primary.withOpacity(0.12)
                  : colorScheme.outlineVariant,
              width: 1,
            ),
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
                        color: isDark ? Colors.white : colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.user.email,
                      style: AppTheme.bodySmall.copyWith(
                        color: isDark
                            ? colorScheme.onSurfaceVariant.withOpacity(0.75)
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? colorScheme.primary.withOpacity(0.2)
                            : colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        TranslationKeys.settingsPatientBadge.tr,
                        style: AppTheme.labelMedium.copyWith(
                          color: isDark
                              ? colorScheme.primaryFixed
                              : colorScheme.onSecondaryContainer,
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
                color: isDark
                    ? colorScheme.primary.withOpacity(0.6)
                    : colorScheme.outline,
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
        title: TranslationKeys.settingsAccountProfile.tr,
        children: [
          SettingsTile(
            icon: 'person',
            title: TranslationKeys.settingsEditPersonalInfo.tr,
            subtitle: TranslationKeys.settingsEditPersonalInfoDesc.tr,
            onTap: () => Get.toNamed('/patient/profile/edit')?.then((result) {
              if (result == true) {
                controller.refreshProfile();
              }
            }),
            isFirst: true,
          ),
          SettingsTile(
            icon: 'lock_outline',
            title: TranslationKeys.settingsChangePassword.tr,
            subtitle: TranslationKeys.settingsChangePasswordDesc.tr,
            onTap: () => Get.toNamed(AppRoutes.patientChangePassword),
            isLast: true,
          ),
          SettingsTile(
            icon: 'medical_services',
            title: TranslationKeys.settingsPatientProfile.tr,
            subtitle: TranslationKeys.settingsPatientProfileDesc.tr,
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

  Widget _buildPatientProfileSection(BuildContext context) {
    return Obx(() {
      final patientProfile = controller.profileData.value?.patientProfile;

      return SettingsSection(
        title: TranslationKeys.settingsPatientProfile.tr,
        children: [
          SettingsTile(
            icon: 'calendar_today',
            title: TranslationKeys.settingsDateOfBirth.tr,
            subtitle: patientProfile?.dateOfBirth != null
                ? '${patientProfile!.dateOfBirth!.day}/${patientProfile.dateOfBirth!.month}/${patientProfile.dateOfBirth!.year}'
                : TranslationKeys.settingsNotSet.tr,
            onTap: () => _showDateOfBirthDialog(),
            isFirst: true,
          ),
          SettingsTile(
            icon: 'pregnant_woman',
            title: TranslationKeys.settingsLmpDate.tr,
            subtitle: patientProfile?.lmpDate != null
                ? '${patientProfile!.lmpDate!.day}/${patientProfile.lmpDate!.month}/${patientProfile.lmpDate!.year}'
                : TranslationKeys.settingsNotSet.tr,
            onTap: () => _showLmpDateDialog(context),
          ),
          SettingsTile(
            icon: 'pregnant_woman',
            title: TranslationKeys.settingsPregnancyDates.tr,
            subtitle: _buildPregnancySubtitle(patientProfile),
            onTap: () => _showPregnancyDatesDialog(),
          ),
          SettingsTile(
            icon: 'bloodtype',
            title: TranslationKeys.settingsBloodGroup.tr,
            subtitle:
                patientProfile?.bloodGroupDisplay ??
                TranslationKeys.settingsNotSet.tr,
            onTap: () => _showBloodGroupDialog(context),
          ),
          SettingsTile(
            icon: 'contact_emergency',
            title: TranslationKeys.settingsEmergencyContact.tr,
            subtitle:
                patientProfile?.emergencyContactDisplay ??
                TranslationKeys.settingsNotSet.tr,
            onTap: () => _showEmergencyContactDialog(),
          ),
          SettingsTile(
            icon: 'location_on',
            title: TranslationKeys.settingsAddress.tr,
            subtitle:
                patientProfile?.addressDisplay ??
                TranslationKeys.settingsNotSet.tr,
            onTap: () => _showAddressDialog(),
            isLast: true,
          ),
        ],
      );
    });
  }

  String _buildPregnancySubtitle(PatientProfile? profile) {
    if (profile == null) return TranslationKeys.settingsNotSet.tr;
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
    return parts.isEmpty
        ? TranslationKeys.settingsNotSet.tr
        : parts.join(' • ');
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
      title: TranslationKeys.settingsAppPreferences.tr,
      children: [
        SettingsToggleTile(
          icon: 'dark_mode',
          title: TranslationKeys.settingsDarkMode.tr,
          value: controller.isDarkMode.value,
          onChanged: controller.toggleTheme,
          isFirst: true,
        ),
        SettingsToggleTile(
          icon: 'notifications_active',
          title: TranslationKeys.settingsPushNotifications.tr,
          subtitle: TranslationKeys.settingsPushNotificationsDesc.tr,
          value: controller.areNotificationsEnabled.value,
          onChanged: controller.toggleNotifications,
        ),
        SettingsTile(
          icon: 'language',
          title: TranslationKeys.settingsLanguage.tr,
          subtitle: controller.selectedLanguage.value == 'ur_PK'
              ? 'اردو'
              : 'English',
          onTap: controller.showLanguageDialog,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: SettingsTile(
        icon: 'logout',
        title: TranslationKeys.settingsLogout.tr,
        textColor: Theme.of(context).colorScheme.error,
        iconColor: Theme.of(context).colorScheme.error,
        onTap: controller.showLogoutDialog,
        isOnly: true,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //   DATE PICKERS — using AppDatePicker for dark mode compatibility
  // ═══════════════════════════════════════════════════════════════════

  void _showDateOfBirthDialog() {
    final profile = controller.profileData.value?.patientProfile;
    DateTime? selectedDate = profile?.dateOfBirth;
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 100);
    final lastDate = now;

    AppDatePicker.show(
      context: Get.context!,
      initialDate: selectedDate ?? DateTime(now.year - 25),
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select Date of Birth',
    ).then((picked) {
      if (picked != null && picked != selectedDate) {
        controller.updatePatientProfile(dateOfBirth: picked);
      }
    });
  }

  void _showLmpDateDialog(BuildContext context) {
    final profile = controller.profileData.value?.patientProfile;
    final lmpController = TextEditingController(
      text: profile?.lmpDate != null
          ? '${profile!.lmpDate!.day}/${profile.lmpDate!.month}/${profile.lmpDate!.year}'
          : '',
    );

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Last Menstrual Period Date'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'LMP',
              style: AppTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
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
                final picked = await AppDatePicker.show(
                  context: Get.context!,
                  initialDate: profile?.lmpDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(
                    const Duration(days: 365 * 40),
                  ),
                  lastDate: DateTime.now(),
                  helpText: 'Select LMP Date',
                );
                if (picked != null) {
                  lmpController.text =
                      '${picked.day}/${picked.month}/${picked.year}';
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(TranslationKeys.commonCancel.tr),
          ),
          ElevatedButton(
            onPressed: () {
              DateTime? lmpDate;
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
              Get.back();
              if (lmpDate != null) {
                controller.updatePatientProfile(lmpDate: lmpDate);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text(TranslationKeys.commonSave.tr),
          ),
        ],
      ),
    );
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
            Text(
              'LMP',
              style: AppTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
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
                final picked = await AppDatePicker.show(
                  context: Get.context!,
                  initialDate: profile?.lmpDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 300)),
                  lastDate: DateTime.now(),
                  helpText: 'Select LMP Date',
                );
                if (picked != null) {
                  lmpController.text =
                      '${picked.day}/${picked.month}/${picked.year}';
                }
              },
            ),
            const SizedBox(height: 12),
            Text(
              'EDD',
              style: AppTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
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
                final picked = await AppDatePicker.show(
                  context: Get.context!,
                  initialDate:
                      profile?.eddDate ??
                      DateTime.now().add(const Duration(days: 280)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 300)),
                  helpText: 'Select EDD Date',
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
          TextButton(
            onPressed: () => Get.back(),
            child: Text(TranslationKeys.commonCancel.tr),
          ),
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
            child: Text(TranslationKeys.commonSave.tr),
          ),
        ],
      ),
    );
  }

  void _showBloodGroupDialog(BuildContext context) {
    final profile = controller.profileData.value?.patientProfile;
    final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ Use the SAME background color for all items (selected or not)
    final itemBgColor = colorScheme.background;
    // ✅ Text color = dark on light background
    final itemTextColor = colorScheme.onBackground;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: isDark
            ? colorScheme.surfaceContainerLow
            : colorScheme.surfaceContainerLowest,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        title: Text(
          'Blood Group',
          style: TextStyle(
            color: isDark ? colorScheme.primaryFixed : colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: bloodGroups.map((group) {
                final isSelected = profile?.bloodGroup == group;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    // ✅ Same white/light background for both selected & unselected
                    color: itemBgColor,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        controller.updatePatientProfile(bloodGroup: group);
                        Get.back();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          // ✅ Selected = pink border, Unselected = subtle border
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.outlineVariant.withOpacity(0.4),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // ✅ Blood group text — dark on white bg
                            Expanded(
                              child: Text(
                                group,
                                style: AppTheme.bodyLarge.copyWith(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : itemTextColor,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                            // ✅ Selected indicator (pink checkmark)
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                size: 20,
                                color: colorScheme.primary,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              TranslationKeys.commonCancel.tr,
              style: TextStyle(
                color: isDark ? colorScheme.primaryFixed : colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
          TextButton(
            onPressed: () => Get.back(),
            child: Text(TranslationKeys.commonCancel.tr),
          ),
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
            child: Text(TranslationKeys.commonSave.tr),
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
          TextButton(
            onPressed: () => Get.back(),
            child: Text(TranslationKeys.commonCancel.tr),
          ),
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
            child: Text(TranslationKeys.commonSave.tr),
          ),
        ],
      ),
    );
  }
}
