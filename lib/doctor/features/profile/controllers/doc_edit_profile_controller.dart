// lib/features/profile/controllers/edit_profile_controller.dart

import 'package:doctor/core/constants/app_constants.dart';
import 'package:doctor/core/network/api_exceptions.dart';
import 'package:doctor/doctor/features/profile/models/doc_edit_profile_model.dart';
import 'package:doctor/doctor/features/profile/repositories/doc_edit_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorEditProfileController extends GetxController {
  final DoctorEditProfileRepository _repository = DoctorEditProfileRepository();

  // Form controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final specializationController = TextEditingController();
  final licenseNumberController = TextEditingController();
  final yearsExperienceController = TextEditingController();
  final bioController = TextEditingController();
  final cityController = TextEditingController();
  final areaController = TextEditingController();
  final consultationFeeController = TextEditingController();

  // Form state
  final isAcceptingPatients = true.obs;
  final isLoading = true.obs;
  final isSaving = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Profile data
  final profile = Rxn<DoctorProfileResponse>();
  final doctorProfile = Rxn<DoctorProfileData>();

  // Validation errors
  final firstNameError = ''.obs;
  final lastNameError = ''.obs;
  final phoneNumberError = ''.obs;
  final consultationFeeError = ''.obs;
  final cityError = ''.obs;

  // City options from AppConstants
  List<String> get cityOptions =>
      AppConstants.cities.map((c) => c.toLowerCase()).toList();

  String get displayCity {
    final city = doctorProfile.value?.city ?? '';
    if (city.isEmpty) return '';
    // Capitalize first letter
    return city.substring(0, 1).toUpperCase() + city.substring(1);
  }

  String get displayName {
    final first = firstNameController.text.trim();
    final last = lastNameController.text.trim();
    if (first.isEmpty && last.isEmpty) return 'Doctor';
    return '$first $last'.trim();
  }

  String get profileImageUrl {
    // Return placeholder or actual image URL
    return 'https://lh3.googleusercontent.com/aida-public/AB6AXuBiw7SYmzasWHgslU9N15rx6URNP9BO7tN0P-8qRZ2OZYX5oCS2kJClCbsaHBUwlHjF4QDrfcgyjT-A59kXCuaeSx1o_EQcVZb3eE3jfm5rQut_u0ZFnRJ0EJyUcdXmtnJEZzSC-7potk55SSxp92B5eyaJXTDiaK4VqwZcHilyHgqXVSKwtR91f_Y63iGKsrTQPqCLo1N7mmgfn8xmg3ACMdl0d3ZGyaAHcBm1wXQgxkpnqX0GSsdV';
  }

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final data = await _repository.getProfile();
      if (data != null) {
        profile.value = data;
        doctorProfile.value = data.doctorProfile;
        _populateForm(data);
      } else {
        throw Exception('Failed to load profile data');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      debugPrint('[EDIT_PROFILE] Error loading profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _populateForm(DoctorProfileResponse data) {
    firstNameController.text = data.firstName;
    lastNameController.text = data.lastName;
    phoneNumberController.text = data.phoneNumber;

    final docProfile = data.doctorProfile;
    if (docProfile != null) {
      specializationController.text = docProfile.specialization ?? '';
      licenseNumberController.text = docProfile.licenseNumber ?? '';
      yearsExperienceController.text =
          docProfile.yearsOfExperience?.toString() ?? '';
      bioController.text = docProfile.bio ?? '';
      isAcceptingPatients.value = docProfile.isAcceptingPatients;
      cityController.text = docProfile.city ?? '';
      areaController.text = docProfile.area ?? '';
      consultationFeeController.text =
          docProfile.consultationFee?.toStringAsFixed(0) ?? '';
    }
  }

  /// Update form fields with new data after save
  void _updateFormWithNewData(DoctorProfileResponse newData) {
    // Update user fields
    firstNameController.text = newData.firstName;
    lastNameController.text = newData.lastName;
    phoneNumberController.text = newData.phoneNumber;

    // Update doctor profile fields
    final docProfile = newData.doctorProfile;
    if (docProfile != null) {
      specializationController.text = docProfile.specialization ?? '';
      licenseNumberController.text = docProfile.licenseNumber ?? '';
      yearsExperienceController.text =
          docProfile.yearsOfExperience?.toString() ?? '';
      bioController.text = docProfile.bio ?? '';
      isAcceptingPatients.value = docProfile.isAcceptingPatients;
      cityController.text = docProfile.city ?? '';
      areaController.text = docProfile.area ?? '';
      consultationFeeController.text =
          docProfile.consultationFee?.toStringAsFixed(0) ?? '';
    }

    // Update observable profile data
    profile.value = newData;
    doctorProfile.value = newData.doctorProfile;
  }

  bool validateForm() {
    bool isValid = true;

    // Validate first name
    if (firstNameController.text.trim().isEmpty) {
      firstNameError.value = 'First name is required';
      isValid = false;
    } else {
      firstNameError.value = '';
    }

    // Validate last name
    if (lastNameController.text.trim().isEmpty) {
      lastNameError.value = 'Last name is required';
      isValid = false;
    } else {
      lastNameError.value = '';
    }

    // Validate phone number
    if (phoneNumberController.text.trim().isEmpty) {
      phoneNumberError.value = 'Phone number is required';
      isValid = false;
    } else if (phoneNumberController.text.trim().length < 10) {
      phoneNumberError.value = 'Please enter a valid phone number';
      isValid = false;
    } else {
      phoneNumberError.value = '';
    }

    // Validate city
    if (cityController.text.trim().isEmpty) {
      cityError.value = 'Please select a city';
      isValid = false;
    } else {
      cityError.value = '';
    }

    // Validate consultation fee (optional but must be positive if provided)
    final feeText = consultationFeeController.text.trim();
    if (feeText.isNotEmpty) {
      final fee = double.tryParse(feeText);
      if (fee == null || fee < 0) {
        consultationFeeError.value = 'Please enter a valid amount';
        isValid = false;
      } else {
        consultationFeeError.value = '';
      }
    } else {
      consultationFeeError.value = '';
    }

    return isValid;
  }

  Future<void> saveProfile() async {
    if (!validateForm()) return;

    isSaving.value = true;

    try {
      // Build user profile update request
      final userRequest = UserProfileUpdateRequest(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        phoneNumber: phoneNumberController.text.trim(),
      );

      // Build doctor profile update request
      final feeText = consultationFeeController.text.trim();
      final doctorRequest = DoctorProfileUpdateRequest(
        specialization: specializationController.text.trim().isEmpty
            ? null
            : specializationController.text.trim(),
        licenseNumber: licenseNumberController.text.trim().isEmpty
            ? null
            : licenseNumberController.text.trim(),
        yearsOfExperience: yearsExperienceController.text.trim().isEmpty
            ? null
            : int.tryParse(yearsExperienceController.text.trim()),
        bio: bioController.text.trim().isEmpty
            ? null
            : bioController.text.trim(),
        isAcceptingPatients: isAcceptingPatients.value,
        city: cityController.text.trim().isEmpty
            ? null
            : cityController.text.trim(),
        area: areaController.text.trim().isEmpty
            ? null
            : areaController.text.trim(),
        consultationFee: feeText.isEmpty ? null : double.tryParse(feeText),
      );

      final result = await _repository.updateFullProfile(
        userRequest: userRequest,
        doctorRequest: doctorRequest,
      );

      if (result != null) {
        // Update the form with the new data
        _updateFormWithNewData(result);

        Get.back(result: true);
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green[800],
        );
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      if (e is ApiException && e.fieldErrors != null) {
        final errors = e.fieldErrors!;
        if (errors['city'] != null) {
          cityError.value = errors['city']!.first;
        }
        if (errors['first_name'] != null) {
          firstNameError.value = errors['first_name']!.first;
        }
        if (errors['last_name'] != null) {
          lastNameError.value = errors['last_name']!.first;
        }
        if (errors['phone_number'] != null) {
          phoneNumberError.value = errors['phone_number']!.first;
        }
        if (errors['consultation_fee'] != null) {
          consultationFeeError.value = errors['consultation_fee']!.first;
        }
        if (errors['specialization'] != null) {
          // specialization doesn't have a local error var, show snackbar
          Get.snackbar(
            'Error',
            errors['specialization']!.first,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red[800],
          );
        }
      } else {
        Get.snackbar(
          'Error',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[800],
        );
      }
    } finally {
      isSaving.value = false;
    }
  }

  void cancel() {
    Get.back();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    specializationController.dispose();
    licenseNumberController.dispose();
    yearsExperienceController.dispose();
    bioController.dispose();
    cityController.dispose();
    areaController.dispose();
    consultationFeeController.dispose();
    super.onClose();
  }
}
