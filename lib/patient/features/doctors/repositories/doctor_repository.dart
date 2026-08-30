// lib/patient/features/doctors/repositories/doctor_repository.dart

import 'package:dio/dio.dart';
import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/network/api_error_mapper.dart';
import 'package:doctor/patient/features/doctors/models/doctor.dart';
import 'package:doctor/patient/features/doctors/models/paginated_doctor_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Get paginated list of doctors with filters
  Future<PaginatedDoctorList?> getDoctors({
    int page = 1,
    int pageSize = 20,
    String? city,
    String? area,
    double? lat,
    double? lng,
    double? radiusKm,
  }) async {
    try {
      // ✅ FIX: Explicitly type as Map<String, dynamic>
      final Map<String, dynamic> queryParams = {
        'page': page,
        'page_size': pageSize,
      };

      if (city != null && city.isNotEmpty) {
        queryParams['city'] = city;
      }
      if (area != null && area.isNotEmpty) {
        queryParams['area'] = area;
      }
      if (lat != null) {
        queryParams['lat'] = lat;
      }
      if (lng != null) {
        queryParams['lng'] = lng;
      }
      if (radiusKm != null) {
        queryParams['radius_km'] = radiusKm;
      }

      final response = await _apiClient.get(
        ApiConstants.accountsDoctors,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return PaginatedDoctorList.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load doctors.',
      );
      debugPrint('[DOCTOR_REPO] Error: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[DOCTOR_REPO] Unexpected error: $e');
      return null;
    }
  }

  /// Get a single doctor by ID
  Future<Doctor?> getDoctorById(int id) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.accountsDoctorsDetail}/$id/',
      );

      if (response.statusCode == 200) {
        return Doctor.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get doctor details.',
      );
      debugPrint('[DOCTOR_REPO] Error getting doctor: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[DOCTOR_REPO] Unexpected error: $e');
      return null;
    }
  }

  /// Book an appointment with a doctor
  // Future<DoctorAppointment?> bookAppointment({
  //   required int doctorId,
  //   required DateTime scheduledAt,
  //   String? reason,
  //   String appointmentType = 'in_person',
  //   int durationMinutes = 30,
  //   int? patientId,
  // }) async {
  //   try {
  //     final Map<String, dynamic> data = {
  //       'doctor_id': doctorId,
  //       'scheduled_at': scheduledAt.toIso8601String(),
  //       'appointment_type': appointmentType,
  //       'duration_minutes': durationMinutes,
  //     };

  //     if (reason != null && reason.isNotEmpty) {
  //       data['reason'] = reason;
  //     }
  //     if (patientId != null) {
  //       data['patient_id'] = patientId;
  //     }

  //     final response = await _apiClient.post(
  //       ApiConstants.appointments,
  //       data: data,
  //     );

  //     if (response.statusCode == 201) {
  //       return DoctorAppointment.fromJson(
  //         response.data as Map<String, dynamic>,
  //       );
  //     }

  //     return null;
  //   } on DioException catch (e) {
  //     final apiException = ApiErrorMapper.mapDioException(
  //       e,
  //       defaultMessage: 'Failed to book appointment.',
  //     );
  //     debugPrint('[DOCTOR_REPO] Error booking: ${apiException.message}');
  //     return null;
  //   } catch (e) {
  //     debugPrint('[DOCTOR_REPO] Unexpected error: $e');
  //     return null;
  //   }
  // }
}
