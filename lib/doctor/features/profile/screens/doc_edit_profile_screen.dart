// lib/features/profile/screens/edit_profile_screen.dart

import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/services/storage_service.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/doc_top_app_bar.dart';
import 'package:doctor/doctor/features/profile/controllers/doc_edit_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorEditProfileScreen extends GetView<DoctorEditProfileController> {
  const DoctorEditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          const TopAppNavBar(title: 'Edit Profile', showBackButton: true),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState();
              }

              if (controller.hasError.value) {
                return _buildErrorState();
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32.0 : 16.0,
                  vertical: 16.0,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildAvatarHeader(),
                      const SizedBox(height: 24),
                      _buildPersonalInfoSection(),
                      const SizedBox(height: 24),
                      _buildProfessionalDetailsSection(),
                      const SizedBox(height: 24),
                      _buildPracticeLocationSection(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: _buildActionButtons(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Loading profile...',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurfaceVariant,
            ),
          ),
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
                onPressed: () => controller.loadProfile(),
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

  Widget _buildAvatarHeader() {
    final hasLocalImage = controller.selectedImage.value != null;
    final avatarUrl = controller.profileImageUrl;
    final isLocalFile = hasLocalImage;

    return GestureDetector(
      onTap: controller.isUploadingAvatar.value
          ? null
          : controller.showImageSourceBottomSheet,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: isLocalFile
                  ? Image.memory(
                      controller.selectedImageBytes.value!,
                      fit: BoxFit.cover,
                      width: 110,
                      height: 110,
                    )
                  : (avatarUrl.isNotEmpty
                        ? Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                            width: 110,
                            height: 110,
                            headers: _profileImageHeaders,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildInitialsAvatar(),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return _buildInitialsAvatar();
                            },
                          )
                        : _buildInitialsAvatar()),
            ),
          ),
          // Camera badge overlay
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(Get.context!).colorScheme.background,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: controller.isUploadingAvatar.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String>? get _profileImageHeaders {
    final accessToken = StorageService.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) return null;
    return {'Authorization': 'Bearer $accessToken'};
  }

  Widget _buildInitialsAvatar() {
    final firstName = controller.firstNameController.text;
    final lastName = controller.lastNameController.text;
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    final initials = '$first$last'.toUpperCase();
    if (initials.isEmpty)
      return const Center(
        child: Text(
          'DR',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      );

    return Container(
      width: 110,
      height: 110,
      color: AppColors.primaryContainer,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            color: AppColors.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(context: Get.context!),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Personal Information',
                style: AppTheme.headlineSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.surfaceContainer, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'First Name *',
                  controller: controller.firstNameController,
                  error: controller.firstNameError,
                  hint: 'Enter first name',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  label: 'Last Name *',
                  controller: controller.lastNameController,
                  error: controller.lastNameError,
                  hint: 'Enter last name',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Phone Number *',
            controller: controller.phoneNumberController,
            error: controller.phoneNumberError,
            hint: 'Enter phone number',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildReadOnlyField(
            label: 'Email',
            value: controller.profile.value?.email ?? '',
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(context: Get.context!),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  size: 18,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Professional Details',
                style: AppTheme.headlineSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.surfaceContainer, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Specialization',
                  controller: controller.specializationController,
                  hint: 'e.g. OB-GYN',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  label: 'License Number',
                  controller: controller.licenseNumberController,
                  hint: 'e.g. PMDC-54321-P',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Years of Experience',
            controller: controller.yearsExperienceController,
            hint: 'Enter years of experience',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Professional Bio',
            controller: controller.bioController,
            hint: 'Write your professional biography...',
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeLocationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(context: Get.context!),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.tertiaryContainer.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  size: 18,
                  color: AppColors.tertiaryContainer,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Practice & Location',
                style: AppTheme.headlineSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.surfaceContainer, height: 1),
          const SizedBox(height: 16),
          // Toggle - reactive via outer Obx
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Accepting New Patients',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Toggle if you are currently taking new bookings.',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.isAcceptingPatients.toggle(),
                  child: Container(
                    width: 44,
                    height: 24,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: controller.isAcceptingPatients.value
                          ? AppColors.secondary
                          : AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: controller.isAcceptingPatients.value
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Consultation Fee',
                  controller: controller.consultationFeeController,
                  error: controller.consultationFeeError,
                  hint: 'e.g. 3500',
                  keyboardType: TextInputType.number,
                  prefix: 'PKR',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'City',
                  value: controller.cityController.text.isNotEmpty
                      ? controller.cityController.text[0].toUpperCase() +
                            controller.cityController.text.substring(1)
                      : null,
                  options: controller.cityOptions.map((city) {
                    final display =
                        city.substring(0, 1).toUpperCase() + city.substring(1);
                    return DropdownMenuItem(
                      value: display,
                      child: Text(display),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      // Store in lowercase for API
                      controller.cityController.text = value.toLowerCase();
                    }
                  },
                  error: controller.cityError,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Area / Neighborhood',
            controller: controller.areaController,
            hint: 'e.g. DHA Phase 5',
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    RxString? error,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? prefix,
  }) {
    // Only use Obx if there's an error observable that can change
    if (error != null) {
      return Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: AppTheme.labelMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (label.contains('*'))
                  const Text(' *', style: TextStyle(color: AppColors.error)),
              ],
            ),
            const SizedBox(height: 4),
            _buildTextFieldWithDecoration(
              controller: controller,
              hint: hint,
              keyboardType: keyboardType,
              maxLines: maxLines,
              prefix: prefix,
              errorText: error.value.isNotEmpty ? error.value : null,
            ),
          ],
        ),
      );
    }

    // No Obx needed for fields without errors
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTheme.labelMedium.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (label.contains('*'))
              const Text(' *', style: TextStyle(color: AppColors.error)),
          ],
        ),
        const SizedBox(height: 4),
        _buildTextFieldWithDecoration(
          controller: controller,
          hint: hint,
          keyboardType: keyboardType,
          maxLines: maxLines,
          prefix: prefix,
          errorText: null,
        ),
      ],
    );
  }

  Widget _buildTextFieldWithDecoration({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? prefix,
    String? errorText,
  }) {
    if (prefix != null) {
      return TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.onSurfaceVariant.withOpacity(0.5),
          ),
          prefixText: '$prefix ',
          prefixStyle: TextStyle(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.outlineVariant, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.outlineVariant, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.secondary, width: 2),
          ),
          errorText: errorText,
          errorStyle: AppTheme.bodySmall.copyWith(
            color: AppColors.error,
            fontSize: 12,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      );
    }

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.onSurfaceVariant.withOpacity(0.5),
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.secondary, width: 2),
        ),
        errorText: errorText,
        errorStyle: AppTheme.bodySmall.copyWith(
          color: AppColors.error,
          fontSize: 12,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.labelMedium.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outlineVariant, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const Icon(
                Icons.lock_outline_rounded,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required List<DropdownMenuItem<T>> options,
    required T? value,
    required void Function(T?) onChanged,
    RxString? error,
  }) {
    if (error != null) {
      return Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTheme.labelMedium.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: error.value.isNotEmpty
                      ? AppColors.error
                      : AppColors.outlineVariant,
                  width: 1,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  value: value,
                  isExpanded: true,
                  items: options,
                  onChanged: onChanged,
                  hint: Text(
                    'Select $label',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant.withOpacity(0.5),
                    ),
                  ),
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppColors.onSurface,
                  ),
                  icon: Icon(
                    Icons.arrow_drop_down_rounded,
                    color: AppColors.onSurfaceVariant,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ),
            if (error.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 12),
                child: Text(
                  error.value,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.labelMedium.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outlineVariant, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              items: options,
              onChanged: onChanged,
              hint: Text(
                'Select $label',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant.withOpacity(0.5),
                ),
              ),
              style: AppTheme.bodyMedium.copyWith(color: AppColors.onSurface),
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                color: AppColors.onSurfaceVariant,
              ),
              borderRadius: BorderRadius.circular(8),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.outlineVariant, width: 1),
          ),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: controller.isSaving.value
                      ? null
                      : controller.cancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    disabledForegroundColor: AppColors.onSurfaceVariant
                        .withOpacity(0.4),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.05,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: controller.isSaving.value
                      ? null
                      : controller.saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                    disabledForegroundColor: AppColors.onPrimary.withOpacity(
                      0.6,
                    ),
                  ),
                  child: controller.isSaving.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.05,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
