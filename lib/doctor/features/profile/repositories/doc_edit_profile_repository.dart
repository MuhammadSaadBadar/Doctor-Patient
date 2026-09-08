// lib/features/profile/repositories/edit_profile_repository.dart

import 'dart:typed_data';

import 'package:dio/dio.dart' as dio_pkg;
import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/network/api_error_mapper.dart';
import 'package:doctor/doctor/features/profile/models/doc_edit_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorEditProfileRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Get current user profile (including doctor profile)
  Future<DoctorProfileResponse?> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.authMe);

      debugPrint('[EDIT_PROFILE] API Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return DoctorProfileResponse.fromJson(data);
      }

      return null;
    } on dio_pkg.DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load profile.',
      );
      debugPrint('[EDIT_PROFILE] Error: ${apiException.message}');
      throw apiException;
    } catch (e) {
      debugPrint('[EDIT_PROFILE] Unexpected error: $e');
      throw Exception('Failed to load profile. Please try again.');
    }
  }

  /// Upload profile picture (multipart/form-data) using raw bytes.
  ///
  /// Reads bytes once on the caller side (controller) so the upload works
  /// uniformly on Android, iOS, and desktop.
  ///
  /// Returns the profile picture URL directly from the response.
  /// The API returns `DoctorProfile` directly (not wrapped in `doctor_profile`),
  /// with `profile_picture_url` at the top level.
  Future<String?> uploadProfilePicture(
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      final formData = dio_pkg.FormData.fromMap({
        'image': dio_pkg.MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
      });

      final response = await _apiClient.dio.post(
        ApiConstants.accountsMeDoctorProfilePicture,
        data: formData,
        options: dio_pkg.Options(
          headers: {'Content-Type': 'multipart/form-data'},
          connectTimeout: _apiClient.dio.options.connectTimeout,
          receiveTimeout: _apiClient.dio.options.receiveTimeout,
        ),
      );

      debugPrint(
        '[EDIT_PROFILE] Upload avatar response: ${response.statusCode}',
      );
      debugPrint(
        '[EDIT_PROFILE] Upload avatar body: ${response.data}',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        // API returns DoctorProfile directly with profile_picture_url at TOP LEVEL
        final profilePictureUrl = data['profile_picture_url'] as String?;
        debugPrint(
          '[EDIT_PROFILE] Extracted profile picture URL: $profilePictureUrl',
        );
        return profilePictureUrl;
      }

      return null;
    } on dio_pkg.DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to upload profile picture.',
      );
      debugPrint('[EDIT_PROFILE] Upload avatar error: ${apiException.message}');
      throw apiException;
    } catch (e) {
      debugPrint('[EDIT_PROFILE] Upload avatar unexpected error: $e');
      throw Exception('Failed to upload profile picture. Please try again.');
    }
  }

  /// Update user profile (name, phone)
  Future<DoctorProfileResponse?> updateUserProfile(
    UserProfileUpdateRequest request,
  ) async {
    try {
      final response = await _apiClient.patch(
        ApiConstants.authMe,
        data: request.toJson(),
      );

      debugPrint('[EDIT_PROFILE] Update user response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return DoctorProfileResponse.fromJson(data);
      }

      return null;
    } on dio_pkg.DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to update user profile.',
      );
      debugPrint('[EDIT_PROFILE] Error updating user: ${apiException.message}');
      throw apiException;
    } catch (e) {
      debugPrint('[EDIT_PROFILE] Unexpected error: $e');
      throw Exception('Failed to update profile. Please try again.');
    }
  }

  /// Update doctor profile
  Future<DoctorProfileData?> updateDoctorProfile(
    DoctorProfileUpdateRequest request,
  ) async {
    try {
      final response = await _apiClient.patch(
        ApiConstants.accountsMeDoctorProfile,
        data: request.toJson(),
      );

      debugPrint(
        '[EDIT_PROFILE] Update doctor profile response: ${response.statusCode}',
      );
      debugPrint(
        '[EDIT_PROFILE] Update doctor profile body: ${request.toJson()}',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        debugPrint('[EDIT_PROFILE] Updated doctor profile: $data');
        return DoctorProfileData.fromJson(data);
      }

      return null;
    } on dio_pkg.DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to update professional details.',
      );
      debugPrint(
        '[EDIT_PROFILE] Error updating doctor profile: ${apiException.message}',
      );
      throw apiException;
    } catch (e) {
      debugPrint('[EDIT_PROFILE] Unexpected error: $e');
      throw Exception(
        'Failed to update professional details. Please try again.',
      );
    }
  }

  /// Combined update: both user and doctor profile
  Future<DoctorProfileResponse?> updateFullProfile({
    required UserProfileUpdateRequest userRequest,
    required DoctorProfileUpdateRequest doctorRequest,
  }) async {
    try {
      // First update user profile
      final updatedUser = await updateUserProfile(userRequest);
      if (updatedUser == null) {
        throw Exception('Failed to update user profile');
      }

      // Then update doctor profile
      final updatedDoctor = await updateDoctorProfile(doctorRequest);
      if (updatedDoctor == null) {
        throw Exception('Failed to update doctor profile');
      }

      // Return combined response with the updated doctor profile
      return DoctorProfileResponse(
        id: updatedUser.id,
        email: updatedUser.email,
        firstName: updatedUser.firstName,
        lastName: updatedUser.lastName,
        phoneNumber: updatedUser.phoneNumber,
        isEmailVerified: updatedUser.isEmailVerified,
        role: updatedUser.role,
        dateJoined: updatedUser.dateJoined,
        doctorProfile: updatedDoctor, // Use the updated doctor profile
      );
    } catch (e) {
      debugPrint('[EDIT_PROFILE] Error updating full profile: $e');
      throw Exception('Failed to update profile. Please try again.');
    }
  }
}
