// lib/features/profile/screens/profile_screen.dart

import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/bottom_nav_bar.dart';
import 'package:doctor/core/widgets/doctor_avatar.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';
import 'package:doctor/core/widgets/doc_top_app_bar.dart';
import 'package:doctor/doctor/features/profile/controllers/doc_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorProfileScreen extends GetView<DoctorProfileController> {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          const TopAppNavBar.gradient(
            title: 'Profile',
            height: 64,
            showBackButton: true,
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState();
              }

              if (controller.hasError.value) {
                return _buildErrorState(context);
              }

              if (controller.profileData.value == null) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: controller.refreshProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32.0 : 16.0,
                    vertical: 16.0,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        children: [
                          // Profile Header
                          _buildProfileHeader(),
                          const SizedBox(height: 24),

                          // Stats Grid
                          _buildStatsGrid(context),
                          const SizedBox(height: 24),

                          // Professional Details
                          _buildProfessionalDetails(),
                          const SizedBox(height: 16),

                          // Location & Fee
                          _buildLocationAndFee(),
                          const SizedBox(height: 24),

                          // Action Buttons
                          _buildActionButtons(context),
                          const SizedBox(height: 64),
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

  // ==================== ERROR STATE ====================
  Widget _buildErrorState(BuildContext context) {
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

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: MaterialSymbolIcon(
                  'person',
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Profile Data',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please complete your profile information.',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _navigateToEditProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Complete Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== PROFILE HEADER ====================
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        final profile = controller.profileData.value!;
        final doctorProfile = profile.doctorProfile;

        return Column(
          children: [
            // Avatar
            DoctorAvatar(
              imageUrl: profile.profilePictureUrl,
              firstName: profile.firstName,
              lastName: profile.lastName,
              size: 88,
              enableCacheBusting: true,
            ),
            const SizedBox(height: 12),

            // Name
            Text(
              'Dr. ${profile.firstName} ${profile.lastName}',
              style: AppTheme.getResponsiveHeadline(
                Get.context!,
              ).copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 4),

            // Specialization
            Text(
              doctorProfile?.specialization ?? 'Not Specified',
              style: AppTheme.bodyLarge.copyWith(color: AppColors.onSurface),
            ),
            const SizedBox(height: 6),

            // License Number
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: AppColors.outlineVariant, width: 1),
              ),
              child: Text(
                doctorProfile?.licenseNumber ?? 'License Not Set',
                style: AppTheme.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ==================== STATS GRID ====================
  Widget _buildStatsGrid(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Obx(() {
      final stats = controller.dashboardStats.value;

      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: isTablet ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
        children: [
          _buildStatItem(
            icon: 'group',
            iconColor: AppColors.primary,
            value: stats?.totalAssignedPatients?.toString() ?? '0',
            label: 'Total Patients',
          ),
          _buildStatItem(
            icon: 'check_circle',
            iconColor: AppColors.secondary,
            value: stats?.completedAppointmentsCount?.toString() ?? '0',
            label: 'Completed',
          ),
          _buildStatItem(
            icon: 'star',
            iconColor: AppColors.onTertiaryContainer,
            value: stats?.averageRating != null
                ? '${stats!.averageRating!.toStringAsFixed(1)} ★'
                : '0.0 ★',
            label: 'Rating',
          ),
          _buildStatItem(
            icon: 'reviews',
            iconColor: AppColors.primary,
            value: stats?.totalRatings?.toString() ?? '0',
            label: 'Reviews',
          ),
        ],
      );
    });
  }

  Widget _buildStatItem({
    required String icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MaterialSymbolIcon(icon, size: 28, color: iconColor, fill: true),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.headlineSmall.copyWith(color: AppColors.primary),
          ),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PROFESSIONAL DETAILS ====================
  Widget _buildProfessionalDetails() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Obx(() {
        final profile = controller.profileData.value!;
        final doctorProfile = profile.doctorProfile;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: const BorderRadiusDirectional.only(
                  topStart: Radius.circular(12),
                  topEnd: Radius.circular(12),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.surfaceContainerHighest,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Professional Details',
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: doctorProfile?.isAcceptingPatients == true
                            ? AppColors.secondaryFixed
                            : AppColors.errorContainer,
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(
                          color: doctorProfile?.isAcceptingPatients == true
                              ? AppColors.secondary.withOpacity(0.2)
                              : AppColors.error.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MaterialSymbolIcon(
                            doctorProfile?.isAcceptingPatients == true
                                ? 'check_circle'
                                : 'cancel',
                            size: 14,
                            color: doctorProfile?.isAcceptingPatients == true
                                ? AppColors.onSecondaryFixed
                                : AppColors.error,
                            fill: true,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              doctorProfile?.isAcceptingPatients == true
                                  ? 'Accepting Patients'
                                  : 'Not Accepting',
                              style: AppTheme.labelMedium.copyWith(
                                color:
                                    doctorProfile?.isAcceptingPatients == true
                                    ? AppColors.onSecondaryFixed
                                    : AppColors.error,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailItem(
                    icon: 'mail_outline',
                    label: 'Email',
                    value: profile.email,
                  ),
                  const SizedBox(height: 12),
                  _buildDivider(),
                  const SizedBox(height: 12),
                  _buildDetailItem(
                    icon: 'phone',
                    label: 'Phone',
                    value: profile.phoneNumber ?? 'Not set',
                  ),
                  const SizedBox(height: 12),
                  _buildDivider(),
                  const SizedBox(height: 12),
                  _buildDetailItem(
                    icon: 'work_outline',
                    label: 'Experience',
                    value: doctorProfile?.yearsOfExperience != null
                        ? '${doctorProfile!.yearsOfExperience} years'
                        : 'Not set',
                  ),
                  const SizedBox(height: 12),
                  _buildDivider(),
                  const SizedBox(height: 12),
                  _buildDetailItem(
                    icon: 'description',
                    label: 'Bio',
                    value: doctorProfile?.bio ?? 'No bio available.',
                    isMultiLine: true,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDetailItem({
    required String icon,
    required String label,
    required String value,
    bool isMultiLine = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MaterialSymbolIcon(icon, size: 24, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.labelMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTheme.bodyMedium.copyWith(color: AppColors.onSurface),
                maxLines: isMultiLine ? 5 : 1,
                overflow: isMultiLine
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsetsDirectional.only(start: 44),
      color: AppColors.surfaceContainer,
    );
  }

  // ==================== LOCATION & FEE ====================
  Widget _buildLocationAndFee() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Obx(() {
        final profile = controller.profileData.value!;
        final doctorProfile = profile.doctorProfile;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Location
              Row(
                children: [
                  MaterialSymbolIcon(
                    'location_city',
                    size: 24,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clinic Location',
                          style: AppTheme.labelMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          doctorProfile?.city != null
                              ? '${_capitalize(doctorProfile!.city!)}, ${doctorProfile.area ?? ''}'
                              : 'Location not set',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Open map or edit location
                    },
                    icon: MaterialSymbolIcon(
                      'place',
                      size: 24,
                      color: AppColors.secondary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDivider(),
              const SizedBox(height: 12),

              // Consultation Fee
              Row(
                children: [
                  MaterialSymbolIcon(
                    'payment',
                    size: 24,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consultation Fee',
                          style: AppTheme.labelMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          doctorProfile?.consultationFee != null
                              ? 'PKR ${double.parse(doctorProfile!.consultationFee!).toStringAsFixed(2)}'
                              : 'Fee not set',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  // ==================== ACTION BUTTONS ====================
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _navigateToEditProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Edit Profile'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: () => Get.toNamed(AppRoutes.changePassword),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.surfaceContainerLowest,
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Change Password'),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: TextButton(
            onPressed: () => _showLogoutDialog(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Logout'),
          ),
        ),
      ],
    );
  }

  // ==================== NAVIGATION METHODS ====================

  /// Navigate to Edit Profile screen and refresh on return
  void _navigateToEditProfile() {
    Get.toNamed(AppRoutes.doceditProfile)?.then((result) {
      // Refresh profile data when returning from edit
      if (result == true) {
        controller.refreshProfile();
      }
    });
  }

  // ==================== DIALOGS ====================
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
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
              Navigator.pop(context);
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

  // ==================== HELPERS ====================
  String _getInitials(String firstName, String lastName) {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
