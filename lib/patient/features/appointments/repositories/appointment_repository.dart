// lib/patient/features/appointments/repositories/appointment_repository.dart

import 'package:dio/dio.dart';
import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/network/api_error_mapper.dart';
import 'package:doctor/patient/features/appointments/models/appointment.dart';
import 'package:doctor/patient/features/appointments/models/paginated_appointment_list.dart';
import 'package:doctor/patient/features/appointments/models/platform_payment_method.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppointmentRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Get appointments with pagination and filters
  Future<PaginatedAppointmentList?> getAppointments({
    int page = 1,
    int pageSize = 20,
    String? status,
    int? doctorId,
    int? patientId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'page_size': pageSize,
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (doctorId != null) {
        queryParams['doctor_id'] = doctorId;
      }
      if (patientId != null) {
        queryParams['patient_id'] = patientId;
      }

      final response = await _apiClient.get(
        ApiConstants.appointments,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return PaginatedAppointmentList.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load appointments.',
      );
      debugPrint('[APPOINTMENT_REPO] Error: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[APPOINTMENT_REPO] Unexpected error: $e');
      return null;
    }
  }

  /// Get a single appointment by ID
  Future<Appointment?> getAppointmentById(int id) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.appointmentsDetail}$id/',
      );

      if (response.statusCode == 200) {
        return Appointment.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get appointment details.',
      );
      debugPrint(
        '[APPOINTMENT_REPO] Error getting appointment: ${apiException.message}',
      );
      return null;
    } catch (e) {
      debugPrint('[APPOINTMENT_REPO] Unexpected error: $e');
      return null;
    }
  }

  /// Book a new appointment
  Future<Appointment?> bookAppointment({
    required int doctorId,
    required String appointmentType,
    required DateTime scheduledAt,
    int durationMinutes = 30,
    String? reason,
  }) async {
    try {
      final data = {
        'doctor_id': doctorId,
        'appointment_type': appointmentType,
        'scheduled_at': scheduledAt.toIso8601String(),
        'duration_minutes': durationMinutes,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      };

      final response = await _apiClient.post(
        ApiConstants.appointments,
        data: data,
      );

      if (response.statusCode == 201) {
        return Appointment.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to book appointment.',
      );
      debugPrint('[APPOINTMENT_REPO] Error booking: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[APPOINTMENT_REPO] Unexpected error: $e');
      return null;
    }
  }

  /// Reschedule an appointment
  Future<Appointment?> rescheduleAppointment(
    int id, {
    required DateTime newScheduledAt,
    int? durationMinutes,
  }) async {
    try {
      final data = {
        'scheduled_at': newScheduledAt.toIso8601String(),
        if (durationMinutes != null) 'duration_minutes': durationMinutes,
      };

      final response = await _apiClient.patch(
        '${ApiConstants.appointmentsDetail}$id${ApiConstants.appointmentRescheduleSuffix}',
        data: data,
      );

      if (response.statusCode == 200) {
        return Appointment.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to reschedule appointment.',
      );
      debugPrint(
        '[APPOINTMENT_REPO] Error rescheduling: ${apiException.message}',
      );
      return null;
    } catch (e) {
      debugPrint('[APPOINTMENT_REPO] Unexpected error: $e');
      return null;
    }
  }

  /// Cancel an appointment
  Future<Appointment?> cancelAppointment(int id, {String? reason}) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.appointmentsDetail}$id${ApiConstants.appointmentStatusSuffix}',
        data: {
          'status': 'cancelled',
          if (reason != null && reason.isNotEmpty)
            'cancellation_reason': reason,
        },
      );

      if (response.statusCode == 200) {
        return Appointment.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to cancel appointment.',
      );
      debugPrint(
        '[APPOINTMENT_REPO] Error cancelling: ${apiException.message}',
      );
      return null;
    } catch (e) {
      debugPrint('[APPOINTMENT_REPO] Unexpected error: $e');
      return null;
    }
  }

  /// Mark payment as paid (patient action)
  Future<Appointment?> markPaymentAsPaid(int id) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.appointmentsDetail}$id${ApiConstants.appointmentPaymentMarkPaidSuffix}',
        data: {},
      );

      if (response.statusCode == 200) {
        return Appointment.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to mark payment as paid.',
      );
      debugPrint(
        '[APPOINTMENT_REPO] Error marking payment: ${apiException.message}',
      );
      return null;
    } catch (e) {
      debugPrint('[APPOINTMENT_REPO] Unexpected error: $e');
      return null;
    }
  }

  /// Rate an appointment (patient only, completed appointments only)
  Future<bool> rateAppointment(int id, int score, {String? comment}) async {
    try {
      final Map<String, dynamic> data = {'score': score};
      if (comment != null && comment.isNotEmpty) {
        data['comment'] = comment;
      }

      final response = await _apiClient.post(
        '${ApiConstants.appointmentsDetail}$id${ApiConstants.appointmentRateSuffix}',
        data: data,
      );

      return response.statusCode == 201;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to rate appointment.',
      );
      debugPrint('[APPOINTMENT_REPO] Error rating: ${apiException.message}');
      return false;
    } catch (e) {
      debugPrint('[APPOINTMENT_REPO] Unexpected error: $e');
      return false;
    }
  }

  /// Get available time slots for a doctor on a specific date
  /// NOTE: Backend doesn't currently expose a doctor availability endpoint.
  /// This returns default slots. When backend supports it, replace with actual API call.
  Future<List<TimeOfDay>> getAvailableTimeSlots({
    required int doctorId,
    required DateTime date,
  }) async {
    // TODO: Replace with actual API call when backend supports doctor availability
    // Example endpoint: GET /api/v1/doctors/{id}/availability/?date=YYYY-MM-DD
    return getDefaultTimeSlots();
  }

  /// Default time slots (9 AM - 4:30 PM, 30-minute intervals)
  List<TimeOfDay> getDefaultTimeSlots() {
    return [
      TimeOfDay(hour: 9, minute: 0),
      TimeOfDay(hour: 9, minute: 30),
      TimeOfDay(hour: 10, minute: 0),
      TimeOfDay(hour: 10, minute: 30),
      TimeOfDay(hour: 11, minute: 0),
      TimeOfDay(hour: 11, minute: 30),
      TimeOfDay(hour: 14, minute: 0),
      TimeOfDay(hour: 14, minute: 30),
      TimeOfDay(hour: 15, minute: 0),
      TimeOfDay(hour: 15, minute: 30),
      TimeOfDay(hour: 16, minute: 0),
      TimeOfDay(hour: 16, minute: 30),
    ];
  }

  /// Get platform payment methods
  Future<PlatformPaymentMethod?> getPaymentMethods() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.accountsPaymentMethods,
      );

      if (response.statusCode == 200) {
        return PlatformPaymentMethod.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load payment methods.',
      );
      debugPrint('[APPOINTMENT_REPO] Error: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[APPOINTMENT_REPO] Unexpected error: $e');
      return null;
    }
  }
}
