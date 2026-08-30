// lib/patient/features/doctors/controllers/doctor_detail_controller.dart

import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/patient/features/doctors/models/doctor.dart';
import 'package:doctor/patient/features/doctors/repositories/doctor_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorDetailController extends GetxController {
  final DoctorRepository _repository = Get.find<DoctorRepository>();

  // State
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Data
  final doctor = Rx<Doctor?>(null);

  // Get doctor ID from route arguments
  int? get doctorId => Get.arguments?['doctorId'] as int?;

  @override
  void onInit() {
    super.onInit();
    if (doctorId != null) {
      loadDoctor();
    } else {
      hasError.value = true;
      errorMessage.value = 'Doctor ID not found.';
      isLoading.value = false;
    }
  }

  Future<void> loadDoctor() async {
    if (doctorId == null) return;

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await _repository.getDoctorById(doctorId!);

      if (result != null) {
        doctor.value = result;
        debugPrint('[DOCTOR_DETAIL] Loaded doctor: ${result.fullName}');
      } else {
        hasError.value = true;
        errorMessage.value = 'Doctor not found. Please try again.';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Something went wrong. Please try again.';
      debugPrint('[DOCTOR_DETAIL] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadDoctor();
  }

  // Navigation methods
  void navigateBack() {
    Get.back();
  }

  void navigateToBookAppointment() {
    if (doctor.value != null) {
      Get.toNamed(
        AppRoutes.bookAppointment,
        arguments: {'doctorId': doctor.value!.id},
      );
    }
  }

  void navigateToMessages() {
    if (doctor.value != null) {
      Get.toNamed(
        AppRoutes.docsendMessage,
        arguments: {
          'doctorId': doctor.value!.id,
          'doctorName': doctor.value!.fullName,
        },
      );
    }
  }

  void navigateToPatientList() {
    Get.toNamed(AppRoutes.docpatients);
  }

  void navigateToEditProfile() {
    Get.toNamed(AppRoutes.doceditProfile);
  }

  void navigateToPayoutManagement() {
    Get.toNamed('/admin/payout');
  }

  // Helper methods
  String get formattedFee {
    final fee = doctor.value?.doctorProfile?.consultationFee;
    if (fee == null) return 'Free';
    return 'Rs. ${double.tryParse(fee)?.toStringAsFixed(0) ?? fee}';
  }

  String get displayName {
    final doctorData = doctor.value;
    if (doctorData == null) return '';
    return doctorData.fullName;
  }

  String get displaySpecialty {
    return doctor.value?.doctorProfile?.specialization ??
        'General Practitioner';
  }

  String get displayExperience {
    final years = doctor.value?.doctorProfile?.yearsOfExperience;
    if (years == null) return 'N/A';
    return '$years Years Exp.';
  }

  String get displayLocation {
    final profile = doctor.value?.doctorProfile;
    if (profile == null) return 'Location not available';
    final parts = <String>[];
    if (profile.area != null && profile.area!.isNotEmpty) {
      parts.add(profile.area!);
    }
    if (profile.city != null && profile.city!.isNotEmpty) {
      parts.add(profile.city!);
    }
    return parts.isNotEmpty ? parts.join(', ') : 'Location not available';
  }

  bool get isAcceptingPatients {
    return doctor.value?.doctorProfile?.isAcceptingPatients ?? false;
  }

  String get availabilityText {
    return isAcceptingPatients
        ? 'Accepting New Patients'
        : 'Not Accepting Patients';
  }

  Color get availabilityColor {
    return isAcceptingPatients ? Colors.green : Colors.grey;
  }

  String get formattedRating {
    final rating = doctor.value?.averageRating;
    if (rating == null) return 'N/A';
    return rating.toStringAsFixed(1);
  }

  String get reviewCount {
    final count = doctor.value?.totalRatings ?? 0;
    return '$count Review${count != 1 ? 's' : ''}';
  }

  String get completedVisits {
    final count = doctor.value?.completedAppointmentsCount ?? 0;
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k+';
    }
    return '$count+';
  }

  String get distanceDisplay {
    final distance = doctor.value?.distanceKm;
    if (distance == null) return 'N/A';
    return '${distance.toStringAsFixed(1)} km';
  }

  bool get showDistance => doctor.value?.distanceKm != null;

  bool get isVerified {
    return doctor.value?.doctorProfile?.licenseNumber != null &&
        doctor.value!.doctorProfile!.licenseNumber!.isNotEmpty;
  }

  String get licenseNumber {
    return doctor.value?.doctorProfile?.licenseNumber ?? 'N/A';
  }

  bool get hasBio {
    final bio = doctor.value?.doctorProfile?.bio;
    return bio != null && bio.isNotEmpty;
  }

  String get bio {
    return doctor.value?.doctorProfile?.bio ?? 'No bio available.';
  }

  String get phoneNumber {
    return doctor.value?.phoneNumber ?? 'N/A';
  }

  String get email {
    return doctor.value?.email ?? 'N/A';
  }
}
