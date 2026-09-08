// lib/features/profile/controllers/edit_profile_controller.dart

import 'package:doctor/core/constants/app_constants.dart';
import 'package:doctor/core/network/api_exceptions.dart';
import 'package:doctor/doctor/features/auth/controllers/auth_controller.dart';
import 'package:doctor/doctor/features/dashboard/controllers/doc_dashboard_controller.dart';
import 'package:doctor/doctor/features/profile/controllers/doc_profile_controller.dart';
import 'package:doctor/doctor/features/profile/models/doc_edit_profile_model.dart';
import 'package:doctor/doctor/features/profile/repositories/doc_edit_profile_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class DoctorEditProfileController extends GetxController {
  final DoctorEditProfileRepository _repository = DoctorEditProfileRepository();
  final ImagePicker _imagePicker = ImagePicker();

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

  // Avatar state
  final selectedImage = Rxn<XFile>();
  final selectedImageBytes = Rxn<Uint8List>();
  final isUploadingAvatar = false.obs;

  // Profile data
  final profile = Rxn<DoctorProfileResponse>();
  final doctorProfile = Rxn<DoctorProfileData>();
  int _profileImageVersion = DateTime.now().millisecondsSinceEpoch;

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
    if (selectedImage.value != null) {
      return selectedImage.value!.path;
    }
    final url = doctorProfile.value?.profilePictureUrl ?? '';
    if (url.isEmpty) return '';
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}v=$_profileImageVersion';
  }

  bool get hasProfileImage => profileImageUrl.isNotEmpty;

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
        _profileImageVersion = DateTime.now().millisecondsSinceEpoch;
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

        if (selectedImage.value != null) {
          final imageUploaded = await uploadAvatar(showSuccessMessage: false);
          if (!imageUploaded) {
            throw Exception(
              'Profile details were saved, but the profile picture could not be uploaded.',
            );
          }
        }

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

  /// Show bottom sheet to pick image source
  void showImageSourceBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(Get.context!).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Select Profile Picture',
              style: Theme.of(
                Get.context!,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Take Photo',
                  onTap: () {
                    Get.back();
                    pickImage(ImageSource.camera);
                  },
                ),
                _buildImageSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Choose from Gallery',
                  onTap: () {
                    Get.back();
                    pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: Theme.of(Get.context!).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(
              Get.context!,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  /// Pick image from camera or gallery
  Future<void> pickImage(ImageSource source) async {
    // Request permissions before invoking the native picker.
    final hasPermission = await _ensureSourcePermission(source);
    if (!hasPermission) {
      Get.snackbar(
        'Permission Denied',
        source == ImageSource.camera
            ? 'Camera permission is required to take a photo.'
            : 'Gallery permission is required to choose a photo.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
      );
      return;
    }

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      // Verify the picked file is actually accessible. On Android scoped storage
      // and on some Windows desktop paths, XFile.path can point to a location the
      // current isolate cannot open (the "_Namespace" failure). Guard against it.
      final bytes = await pickedFile.readAsBytes();
      final length = bytes.length;
      if (length > 5 * 1024 * 1024) {
        Get.snackbar(
          'Error',
          'Image size must be less than 5MB',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[800],
        );
        return;
      }

      selectedImage.value = pickedFile;
      selectedImageBytes.value = bytes;
    } catch (e) {
      debugPrint('[EDIT_PROFILE] Error picking image: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
      );
    }
  }

  /// Request the right runtime permission for the given [source]. Returns true
  /// when the caller may proceed with the native picker.
  Future<bool> _ensureSourcePermission(ImageSource source) async {
    try {
      if (kIsWeb) return true;

      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        return status.isGranted;
      }

      // Gallery: on Android 13+ this maps to READ_MEDIA_IMAGES via
      // permission_handler; on older Android it falls back to storage.
      if (defaultTargetPlatform == TargetPlatform.android) {
        final photos = await Permission.photos.request();
        if (photos.isGranted || photos.isLimited) return true;
        // Fallback for older Android versions
        final storage = await Permission.storage.request();
        return storage.isGranted;
      }

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final status = await Permission.photos.request();
        return status.isGranted || status.isLimited;
      }

      // Windows / macOS / Linux desktops: image_picker uses a file picker that
      // does not require a runtime permission.
      return true;
    } catch (e) {
      debugPrint('[EDIT_PROFILE] Permission error: $e');
      // If permission_handler is unavailable on the platform, allow the picker
      // to attempt the operation and surface any native error via the catch
      // above.
      return true;
    }
  }

  /// Upload profile picture to server
  Future<bool> uploadAvatar({bool showSuccessMessage = true}) async {
    final imageFile = selectedImage.value;
    final imageBytes = selectedImageBytes.value;
    if (imageFile == null || imageBytes == null) return true;

    isUploadingAvatar.value = true;

    try {
      final newImageUrl = await _repository.uploadProfilePicture(
        imageBytes,
        imageFile.name,
      );

      if (newImageUrl != null && newImageUrl.isNotEmpty) {
        selectedImage.value = null;
        selectedImageBytes.value = null;
        _profileImageVersion = DateTime.now().millisecondsSinceEpoch;

        // Update local doctorProfile with the new image URL
        if (doctorProfile.value != null) {
          doctorProfile.value = DoctorProfileData(
            specialization: doctorProfile.value!.specialization,
            licenseNumber: doctorProfile.value!.licenseNumber,
            yearsOfExperience: doctorProfile.value!.yearsOfExperience,
            bio: doctorProfile.value!.bio,
            isAcceptingPatients: doctorProfile.value!.isAcceptingPatients,
            city: doctorProfile.value!.city,
            area: doctorProfile.value!.area,
            latitude: doctorProfile.value!.latitude,
            longitude: doctorProfile.value!.longitude,
            consultationFee: doctorProfile.value!.consultationFee,
            profilePictureUrl: newImageUrl,
          );
        }

        // Update global user profile image for cross-screen propagation
        Get.find<AuthController>().updateProfileImage(newImageUrl);

        // Refresh other doctor controllers so their local state syncs
        try {
          Get.find<DoctorProfileController>().refreshProfile();
        } catch (_) {}
        try {
          Get.find<DoctorDashboardController>().refreshDashboard();
        } catch (_) {}

        if (showSuccessMessage) {
          Get.snackbar(
            'Success',
            'Profile picture updated',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green[800],
          );
        }
        return true;
      } else {
        throw Exception('Failed to upload profile picture');
      }
    } catch (e) {
      if (showSuccessMessage) {
        Get.snackbar(
          'Error',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[800],
        );
      }
      return false;
    } finally {
      isUploadingAvatar.value = false;
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
