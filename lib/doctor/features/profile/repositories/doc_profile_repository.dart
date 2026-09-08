import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/network/api_error_mapper.dart';
import 'package:doctor/core/services/storage_service.dart';
import 'package:doctor/doctor/features/profile/models/doc_profile_models.dart';
import 'package:doctor/doctor/features/settings/models/doctor_profile_model.dart';
import 'package:doctor/doctor/features/settings/models/payment_method_model.dart';
import 'package:doctor/core/constants/app_constants.dart';

class DoctorProfileRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final StorageService _storage = Get.find<StorageService>();

  // ==================== GET USER PROFILE ====================
  /// Fetch the current user's profile data
  Future<ProfileData?> getUserProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.authMe);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        debugPrint('[PROFILE] User profile fetched successfully');
        return ProfileData.fromJson(data);
      }

      debugPrint('[PROFILE] Failed to fetch profile: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load profile.',
      );
      debugPrint('[PROFILE] Error: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[PROFILE] Unexpected error: $e');
      return null;
    }
  }

  // ==================== UPDATE PROFILE ====================
  /// Update the current user's basic profile info (first_name, last_name, phone_number)
  Future<ProfileData?> updateUserProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      final response = await _apiClient.patch(
        ApiConstants.authMe,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        debugPrint('[PROFILE] Profile updated successfully');
        return ProfileData.fromJson(data);
      }

      debugPrint('[PROFILE] Failed to update profile: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to update profile.',
      );
      debugPrint('[PROFILE] Update error: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[PROFILE] Update unexpected error: $e');
      return null;
    }
  }

  // ==================== UPDATE DOCTOR PROFILE ====================
  /// Update the doctor's professional profile
  Future<DoctorProfile?> updateDoctorProfile({
    String? specialization,
    String? licenseNumber,
    int? yearsOfExperience,
    String? bio,
    bool? isAcceptingPatients,
    String? city,
    String? area,
    String? latitude,
    String? longitude,
    String? consultationFee,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (specialization != null && specialization.isNotEmpty) {
        data['specialization'] = specialization;
      }
      if (licenseNumber != null && licenseNumber.isNotEmpty) {
        data['license_number'] = licenseNumber;
      }
      if (yearsOfExperience != null) {
        data['years_of_experience'] = yearsOfExperience;
      }
      if (bio != null && bio.isNotEmpty) {
        data['bio'] = bio;
      }
      if (isAcceptingPatients != null) {
        data['is_accepting_patients'] = isAcceptingPatients;
      }
      if (city != null && city.isNotEmpty) {
        data['city'] = AppConstants.getCityApiValue(city);
      }
      if (area != null && area.isNotEmpty) {
        data['area'] = area;
      }
      if (latitude != null && latitude.isNotEmpty) {
        data['latitude'] = latitude;
      }
      if (longitude != null && longitude.isNotEmpty) {
        data['longitude'] = longitude;
      }
      if (consultationFee != null && consultationFee.isNotEmpty) {
        data['consultation_fee'] = consultationFee;
      }

      // If no data to update, return current profile
      if (data.isEmpty) {
        return await getDoctorProfile();
      }

      final response = await _apiClient.patch(
        ApiConstants.accountsMeDoctorProfile,
        data: data,
      );

      if (response.statusCode == 200) {
        debugPrint('[PROFILE] Doctor profile updated successfully');
        return DoctorProfile.fromJson(response.data as Map<String, dynamic>);
      }

      debugPrint(
        '[PROFILE] Failed to update doctor profile: ${response.statusCode}',
      );
      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to update doctor profile.',
      );
      debugPrint(
        '[PROFILE] Doctor profile update error: ${apiException.message}',
      );
      return null;
    } catch (e) {
      debugPrint('[PROFILE] Doctor profile update unexpected error: $e');
      return null;
    }
  }

  // ==================== GET DOCTOR PROFILE ====================
  /// Fetch the doctor's professional profile
  Future<DoctorProfile?> getDoctorProfile() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.accountsMeDoctorProfile,
      );

      if (response.statusCode == 200) {
        debugPrint('[PROFILE] Doctor profile fetched successfully');
        return DoctorProfile.fromJson(response.data as Map<String, dynamic>);
      }

      debugPrint(
        '[PROFILE] Failed to fetch doctor profile: ${response.statusCode}',
      );
      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load doctor profile.',
      );
      debugPrint('[PROFILE] Doctor profile error: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[PROFILE] Doctor profile unexpected error: $e');
      return null;
    }
  }

  // ==================== CHANGE PASSWORD ====================
  /// Change the user's password
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authPasswordChange,
        data: {'old_password': oldPassword, 'new_password': newPassword},
      );

      if (response.statusCode == 200) {
        debugPrint('[PROFILE] Password changed successfully');
        return true;
      }

      debugPrint('[PROFILE] Failed to change password: ${response.statusCode}');
      return false;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to change password.',
      );
      debugPrint('[PROFILE] Change password error: ${apiException.message}');
      return false;
    } catch (e) {
      debugPrint('[PROFILE] Change password unexpected error: $e');
      return false;
    }
  }

  // ==================== LOGOUT ====================
  /// Logout the current user
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.authLogout);
      debugPrint('[PROFILE] Logout API call successful');
    } catch (e) {
      debugPrint('[PROFILE] Logout API error (ignored): $e');
    } finally {
      await _storage.clearAuth();
      debugPrint('[PROFILE] Local auth state cleared');
    }
  }

  // ==================== DASHBOARD STATS ====================
  /// Get doctor dashboard stats for the profile screen
  Future<DoctorDashboardStats?> getDoctorDashboardStats() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.reportsDoctorDashboard,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        debugPrint('[PROFILE] Dashboard stats fetched successfully');
        return DoctorDashboardStats.fromJson(data);
      }

      debugPrint(
        '[PROFILE] Failed to fetch dashboard stats: ${response.statusCode}',
      );
      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load dashboard stats.',
      );
      debugPrint('[PROFILE] Dashboard stats error: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[PROFILE] Dashboard stats unexpected error: $e');
      return null;
    }
  }

  // ==================== PLATFORM PAYMENT METHODS ====================
  /// Get platform payment methods (JazzCash, EasyPaisa, Bank)
  Future<PlatformPaymentMethod?> getPaymentMethods() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.accountsPaymentMethods,
      );

      if (response.statusCode == 200) {
        debugPrint('[PROFILE] Platform payment methods fetched successfully');
        return PlatformPaymentMethod.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      debugPrint(
        '[PROFILE] Failed to fetch payment methods: ${response.statusCode}',
      );
      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load payment methods.',
      );
      debugPrint('[PROFILE] Payment methods error: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[PROFILE] Payment methods unexpected error: $e');
      return null;
    }
  }

  // ==================== DELETE PROFILE PICTURE ====================
  /// Delete the doctor's profile picture
  Future<bool> deleteProfilePicture() async {
    try {
      final response = await _apiClient.delete(
        ApiConstants.accountsMeDoctorProfilePicture,
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        debugPrint('[PROFILE] Profile picture deleted successfully');
        return true;
      }

      debugPrint(
        '[PROFILE] Failed to delete profile picture: ${response.statusCode}',
      );
      return false;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to delete profile picture.',
      );
      debugPrint('[PROFILE] Delete profile picture error: ${apiException.message}');
      return false;
    } catch (e) {
      debugPrint('[PROFILE] Delete profile picture unexpected error: $e');
      return false;
    }
  }
}
