import 'package:dio/dio.dart';
import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/network/api_error_mapper.dart';
import 'package:doctor/core/services/storage_service.dart';
import 'package:doctor/patient/features/settings/models/patient_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PatientSettingsRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final StorageService _storage = Get.find<StorageService>();

  Future<PatientProfileData?> getPatientProfile() async {
    try {
      final userResponse = await _apiClient.get(ApiConstants.authMe);
      if (userResponse.statusCode != 200) {
        debugPrint('[PATIENT_SETTINGS] Failed to fetch user profile: ${userResponse.statusCode}');
        return null;
      }

      final patientResponse = await _apiClient.get(ApiConstants.accountsMePatientProfile);
      if (patientResponse.statusCode != 200) {
        debugPrint('[PATIENT_SETTINGS] Failed to fetch patient profile: ${patientResponse.statusCode}');
        return null;
      }

      final userData = userResponse.data as Map<String, dynamic>;
      final patientData = patientResponse.data as Map<String, dynamic>;

      final combinedData = <String, dynamic>{
        ...userData,
        'patient_profile': patientData,
      };

      debugPrint('[PATIENT_SETTINGS] Profile loaded successfully');
      return PatientProfileData.fromJson(combinedData);
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load profile.',
      );
      debugPrint('[PATIENT_SETTINGS] Error: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[PATIENT_SETTINGS] Unexpected error: $e');
      return null;
    }
  }

  Future<UserProfile?> updateUserProfile({
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
        debugPrint('[PATIENT_SETTINGS] User profile updated successfully');
        return UserProfile.fromJson(response.data as Map<String, dynamic>);
      }

      debugPrint('[PATIENT_SETTINGS] Failed to update user profile: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to update profile.',
      );
      debugPrint('[PATIENT_SETTINGS] Update error: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[PATIENT_SETTINGS] Update unexpected error: $e');
      return null;
    }
  }

  Future<PatientProfile?> updatePatientProfile({
    DateTime? dateOfBirth,
    DateTime? lmpDate,
    DateTime? eddDate,
    String? bloodGroup,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? address,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (dateOfBirth != null) {
        data['date_of_birth'] = dateOfBirth.toIso8601String().split('T')[0];
      }
      if (lmpDate != null) {
        data['lmp_date'] = lmpDate.toIso8601String().split('T')[0];
      }
      if (eddDate != null) {
        data['edd_date'] = eddDate.toIso8601String().split('T')[0];
      }
      if (bloodGroup != null && bloodGroup.isNotEmpty) {
        data['blood_group'] = bloodGroup;
      }
      if (emergencyContactName != null && emergencyContactName.isNotEmpty) {
        data['emergency_contact_name'] = emergencyContactName;
      }
      if (emergencyContactPhone != null && emergencyContactPhone.isNotEmpty) {
        data['emergency_contact_phone'] = emergencyContactPhone;
      }
      if (address != null && address.isNotEmpty) {
        data['address'] = address;
      }

      if (data.isEmpty) {
        return await getPatientProfileOnly();
      }

      final response = await _apiClient.patch(
        ApiConstants.accountsMePatientProfile,
        data: data,
      );

      if (response.statusCode == 200) {
        debugPrint('[PATIENT_SETTINGS] Patient profile updated successfully');
        return PatientProfile.fromJson(response.data as Map<String, dynamic>);
      }

      debugPrint('[PATIENT_SETTINGS] Failed to update patient profile: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to update patient profile.',
      );
      debugPrint('[PATIENT_SETTINGS] Patient profile update error: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[PATIENT_SETTINGS] Patient profile update unexpected error: $e');
      return null;
    }
  }

  Future<PatientProfile?> getPatientProfileOnly() async {
    try {
      final response = await _apiClient.get(ApiConstants.accountsMePatientProfile);
      if (response.statusCode == 200) {
        return PatientProfile.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('[PATIENT_SETTINGS] Get patient profile error: $e');
      return null;
    }
  }

  Future<String?> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authPasswordChange,
        data: {'old_password': oldPassword, 'new_password': newPassword},
      );

      if (response.statusCode == 200) {
        debugPrint('[PATIENT_SETTINGS] Password changed successfully');
        return null;
      }

      final serverMessage = _extractServerMessage(response.data);
      debugPrint('[PATIENT_SETTINGS] Failed to change password: ${response.statusCode}');
      return serverMessage ?? 'Failed to change password.';
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to change password.',
      );
      debugPrint('[PATIENT_SETTINGS] Change password error: ${apiException.message}');
      return apiException.message;
    } catch (e) {
      debugPrint('[PATIENT_SETTINGS] Change password unexpected error: $e');
      return 'An unexpected error occurred.';
    }
  }

  static String? _extractServerMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String && detail.isNotEmpty) return detail;
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
      final errors = data['errors'];
      if (errors != null) return errors.toString();
    }
    return null;
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.authLogout);
      debugPrint('[PATIENT_SETTINGS] Logout API call successful');
    } catch (e) {
      debugPrint('[PATIENT_SETTINGS] Logout API error (ignored): $e');
    } finally {
      await _storage.clearAuth();
      debugPrint('[PATIENT_SETTINGS] Local auth state cleared');
    }
  }

  }