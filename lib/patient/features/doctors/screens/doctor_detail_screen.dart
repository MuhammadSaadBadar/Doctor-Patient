// lib/patient/features/doctors/screens/doctor_detail_screen.dart

import 'package:doctor/patient/features/doctors/controllers/doctor_detail_controller.dart';
import 'package:doctor/patient/features/doctors/widgets/doctor_availability_card.dart';
import 'package:doctor/patient/features/doctors/widgets/doctor_header_card.dart';
import 'package:doctor/patient/features/doctors/widgets/doctor_location_card.dart';
import 'package:doctor/patient/features/doctors/widgets/doctor_practice_details.dart';
import 'package:doctor/patient/features/doctors/widgets/doctor_stats_row.dart';
import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorDetailScreen extends GetView<DoctorDetailController> {
  const DoctorDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: PatientTopAppBar(
        title: 'Doctor Profile',
        trailingActions: [
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
                DoctorHeaderCard(doctor: doctor),
                const SizedBox(height: 16),
                DoctorStatsRow(doctor: doctor),
                const SizedBox(height: 16),
                if (controller.hasBio) ...[
                  _buildBioSection(context, doctor),
                  const SizedBox(height: 16),
                ],
                DoctorPracticeDetails(doctor: doctor),
                const SizedBox(height: 16),
                DoctorLocationCard(doctor: doctor),
                const SizedBox(height: 16),
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
    final textScale = MediaQuery.textScalerOf(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'About ${doctor.firstName}',
            style: TextStyle(
              fontSize: textScale.scale(16).clamp(14.0, 20.0),
              fontWeight: FontWeight.w600,
              color: colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              doctor.doctorProfile?.bio ?? '',
              style: TextStyle(
                fontSize: textScale.scale(12).clamp(10.0, 16.0),
                height: 1.6,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBookingBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Obx(() {
      if (controller.doctor.value == null) return const SizedBox.shrink();

      final doctor = controller.doctor.value!;
      final fee = doctor.doctorProfile?.consultationFee;
      final feeDisplay = fee != null
          ? 'Rs. ${double.tryParse(fee)?.toStringAsFixed(0) ?? fee}'
          : 'Free';

      return Container(
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.08),
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
                          fontSize: textScale.scale(10).clamp(8.0, 14.0),
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          feeDisplay,
                          style: TextStyle(
                            fontSize: textScale.scale(18).clamp(16.0, 24.0),
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: controller.navigateToBookAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(
                      horizontal: textScale.scale(24).clamp(16.0, 40.0),
                      vertical: textScale.scale(12).clamp(10.0, 18.0),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    'Book Appointment',
                    style: TextStyle(
                      fontSize: textScale.scale(14).clamp(12.0, 18.0),
                      fontWeight: FontWeight.w700,
                    ),
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
              color: colorScheme.primaryContainer.withValues(alpha: 0.2),
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
    final textScale = MediaQuery.textScalerOf(context);
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
                fontSize: textScale.scale(16).clamp(14.0, 20.0),
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: textScale.scale(12).clamp(10.0, 16.0),
                  color: colorScheme.onSurfaceVariant,
                ),
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
    final textScale = MediaQuery.textScalerOf(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_rounded,
              size: 64,
              color: colorScheme.outline.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Doctor Not Found',
              style: TextStyle(
                fontSize: textScale.scale(16).clamp(14.0, 20.0),
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                'The doctor you\'re looking for could not be found.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: textScale.scale(12).clamp(10.0, 16.0),
                  color: colorScheme.onSurfaceVariant,
                ),
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
