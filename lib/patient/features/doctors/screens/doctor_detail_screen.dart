// lib/patient/features/doctors/screens/doctor_detail_screen.dart

import 'package:doctor/patient/features/doctors/controllers/doctor_detail_controller.dart';
import 'package:doctor/patient/features/doctors/widgets/doctor_availability_card.dart';
import 'package:doctor/patient/features/doctors/widgets/doctor_header_card.dart';
import 'package:doctor/patient/features/doctors/widgets/doctor_location_card.dart';
import 'package:doctor/patient/features/doctors/widgets/doctor_practice_details.dart';
import 'package:doctor/patient/features/doctors/widgets/doctor_stats_row.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorDetailScreen extends GetView<DoctorDetailController> {
  const DoctorDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: controller.navigateBack,
        ),
        title: Text(
          'Doctor Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.bookmark_border_rounded,
              color: colorScheme.onSurface,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.share_rounded, color: colorScheme.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState(context);
        }

        if (controller.hasError.value) {
          return _buildErrorState(context);
        }

        final doctor = controller.doctor.value;
        if (doctor == null) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            child: Column(
              children: [
                // Doctor Header
                DoctorHeaderCard(doctor: doctor),

                const SizedBox(height: 16),

                // Stats Row
                DoctorStatsRow(doctor: doctor),

                const SizedBox(height: 16),

                // Bio Section
                if (controller.hasBio) ...[
                  _buildBioSection(context, doctor),
                  const SizedBox(height: 16),
                ],

                // Practice Details
                DoctorPracticeDetails(doctor: doctor),

                const SizedBox(height: 16),

                // Location
                DoctorLocationCard(doctor: doctor),

                const SizedBox(height: 16),

                // Availability
                DoctorAvailabilityCard(doctor: doctor),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: _buildStickyBookingBar(context),
    );
  }

  Widget _buildBioSection(BuildContext context, dynamic doctor) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About ${doctor.firstName}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            doctor.doctorProfile?.bio ?? '',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBookingBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      if (controller.doctor.value == null) return const SizedBox.shrink();

      final doctor = controller.doctor.value!;
      final fee = doctor.doctorProfile?.consultationFee;
      final feeDisplay = fee != null
          ? 'Rs. ${double.tryParse(fee)?.toStringAsFixed(0) ?? fee}'
          : 'Free';

      return Container(
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Consultation Fee',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        feeDisplay,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: controller.navigateToBookAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Book Appointment',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading doctor profile...',
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_rounded,
              size: 64,
              color: colorScheme.outline.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Doctor Not Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The doctor you\'re looking for could not be found.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.navigateBack,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Back to Search'),
            ),
          ],
        ),
      ),
    );
  }
}
