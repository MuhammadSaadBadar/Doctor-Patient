import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/network/api_error_mapper.dart';
import 'package:doctor/core/network/api_exceptions.dart';
import 'package:doctor/core/services/storage_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:doctor/doctor/features/appointments/models/doc_appointment_schedule.dart';

class DoctorAppointmentRepository {
  final ApiClient _apiClient;
  final StorageService _storage;

  DoctorAppointmentRepository({ApiClient? apiClient, StorageService? storage})
    : _apiClient = apiClient ?? Get.find<ApiClient>(),
      _storage = storage ?? Get.find<StorageService>();

  // ==================== BOOK APPOINTMENT ====================
  Future<AppointmentSchedule?> bookAppointment({
    required int doctorId,
    required AppointmentType appointmentType,
    required DateTime scheduledAt,
    int? durationMinutes,
    String? reason,
    int? patientId, // Required for doctor/admin booking on behalf of patient
  }) async {
    try {
      final data = <String, dynamic>{
        'doctor': doctorId,
        'appointment_type': appointmentType == AppointmentType.inPerson
            ? 'in_person'
            : 'video_consultation',
        'scheduled_at': scheduledAt.toIso8601String(),
        'duration_minutes': durationMinutes ?? 30,
        if (reason != null) 'reason': reason,
        if (patientId != null) 'patient_id': patientId,
      };

      final response = await _apiClient.post(
        ApiConstants.appointments,
        data: data,
      );

      if (response.statusCode == 201) {
        return AppointmentSchedule.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to book appointment.',
      );
      debugPrint(
        '[APPOINTMENT] Error booking appointment: ${apiException.message}',
      );
      return null;
    } catch (e) {
      debugPrint('[APPOINTMENT] Error booking appointment: $e');
      return null;
    }
  }

  // ==================== GET APPOINTMENTS ====================
  Future<List<AppointmentSchedule>> getAppointments({
    int page = 1,
    int? pageSize,
  }) async {
    try {
      String url = '${ApiConstants.appointments}?page=$page';
      if (pageSize != null) {
        url += '&page_size=$pageSize';
      }

      final response = await _apiClient.get(url);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];
        return results
            .map(
              (item) =>
                  AppointmentSchedule.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }

      return [];
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get appointments.',
      );
      debugPrint(
        '[APPOINTMENT] Error getting appointments: ${apiException.message}',
      );
      return [];
    } catch (e) {
      debugPrint('[APPOINTMENT] Error getting appointments: $e');
      return [];
    }
  }

  // ==================== GET ALL APPOINTMENTS (with pagination) ====================
  Future<AppointmentListResult> getAppointmentsPaginated({
    String status = 'upcoming',
    int page = 1,
    int? pageSize,
  }) async {
    try {
      String backendStatus;
      switch (status) {
        case 'upcoming':
          backendStatus = 'pending,confirmed';
          break;
        case 'completed':
          backendStatus = 'completed';
          break;
        case 'cancelled':
          backendStatus = 'cancelled';
          break;
        default:
          backendStatus = status;
      }

      String url =
          '${ApiConstants.appointments}?status=$backendStatus&page=$page';
      if (pageSize != null) {
        url += '&page_size=$pageSize';
      }

      final response = await _apiClient.get(url);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];
        final appointments = results
            .map(
              (item) =>
                  AppointmentSchedule.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        return AppointmentListResult(
          appointments: appointments,
          count: data['count'] as int? ?? 0,
          next: data['next'] as String?,
          previous: data['previous'] as String?,
        );
      }

      return AppointmentListResult(
        appointments: [],
        count: 0,
        next: null,
        previous: null,
      );
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get appointments.',
      );
      debugPrint(
        '[APPOINTMENT] Error getting appointments: ${apiException.message}',
      );
      return AppointmentListResult(
        appointments: [],
        count: 0,
        next: null,
        previous: null,
      );
    } catch (e) {
      debugPrint('[APPOINTMENT] Error getting appointments: $e');
      return AppointmentListResult(
        appointments: [],
        count: 0,
        next: null,
        previous: null,
      );
    }
  }

  // ==================== GET SINGLE APPOINTMENT ====================
  Future<AppointmentSchedule?> getAppointment(int appointmentId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.appointmentsDetail}/$appointmentId/',
      );

      if (response.statusCode == 200) {
        return AppointmentSchedule.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get appointment.',
      );
      debugPrint(
        '[APPOINTMENT] Error getting appointment: ${apiException.message}',
      );
      return null;
    } catch (e) {
      debugPrint('[APPOINTMENT] Error getting appointment: $e');
      return null;
    }
  }

  // ==================== RESCHEDULE APPOINTMENT ====================
  Future<AppointmentSchedule?> rescheduleAppointment(
    int appointmentId,
    DateTime newScheduledAt, {
    int? durationMinutes,
  }) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConstants.appointmentsDetail}/$appointmentId${ApiConstants.appointmentRescheduleSuffix}',
        data: {
          'scheduled_at': newScheduledAt.toIso8601String(),
          if (durationMinutes != null) 'duration_minutes': durationMinutes,
        },
      );

      if (response.statusCode == 200) {
        return AppointmentSchedule.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to reschedule appointment.',
      );
      debugPrint(
        '[APPOINTMENT] Error rescheduling appointment: ${apiException.message}',
      );
      return null;
    } catch (e) {
      debugPrint('[APPOINTMENT] Error rescheduling appointment: $e');
      return null;
    }
  }

  // ==================== CANCEL APPOINTMENT ====================
  Future<bool> cancelAppointment(int appointmentId, {String? reason}) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.appointmentsDetail}/$appointmentId${ApiConstants.appointmentStatusSuffix}',
        data: {'status': 'cancelled', 'cancellation_reason': reason ?? ''},
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to cancel appointment.',
      );
      debugPrint(
        '[APPOINTMENT] Error canceling appointment: ${apiException.message}',
      );
      return false;
    } catch (e) {
      debugPrint('[APPOINTMENT] Error canceling appointment: $e');
      return false;
    }
  }

  // ==================== CONFIRM APPOINTMENT ====================
  Future<AppointmentSchedule?> confirmAppointment(int appointmentId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.appointmentsDetail}/$appointmentId${ApiConstants.appointmentStatusSuffix}',
        data: {'status': 'confirmed'},
      );

      if (response.statusCode == 200) {
        return AppointmentSchedule.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to confirm appointment.',
      );
      debugPrint(
        '[APPOINTMENT] Error confirming appointment: ${apiException.message}',
      );
      return null;
    } catch (e) {
      debugPrint('[APPOINTMENT] Error confirming appointment: $e');
      return null;
    }
  }

  // ==================== COMPLETE APPOINTMENT ====================
  Future<AppointmentSchedule?> completeAppointment(int appointmentId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.appointmentsDetail}/$appointmentId${ApiConstants.appointmentStatusSuffix}',
        data: {'status': 'completed'},
      );

      if (response.statusCode == 200) {
        return AppointmentSchedule.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to complete appointment.',
      );
      debugPrint(
        '[APPOINTMENT] Error completing appointment: ${apiException.message}',
      );
      return null;
    } catch (e) {
      debugPrint('[APPOINTMENT] Error completing appointment: $e');
      return null;
    }
  }

  // ==================== RATE APPOINTMENT ====================
  Future<bool> rateAppointment(
    int appointmentId,
    int score, {
    String? comment,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.appointmentsDetail}/$appointmentId${ApiConstants.appointmentRateSuffix}',
        data: {'score': score, if (comment != null) 'comment': comment},
      );

      return response.statusCode == 201;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to rate appointment.',
      );
      debugPrint(
        '[APPOINTMENT] Error rating appointment: ${apiException.message}',
      );
      return false;
    } catch (e) {
      debugPrint('[APPOINTMENT] Error rating appointment: $e');
      return false;
    }
  }

  // ==================== GET DOCTOR NOTES ====================
  Future<String?> getDoctorNotes(int appointmentId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.appointmentsDetail}/$appointmentId${ApiConstants.appointmentDoctorNotesSuffix}',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['doctor_notes'] as String?;
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get doctor notes.',
      );
      debugPrint(
        '[APPOINTMENT] Error getting doctor notes: ${apiException.message}',
      );
      return null;
    } catch (e) {
      debugPrint('[APPOINTMENT] Error getting doctor notes: $e');
      return null;
    }
  }

  // ==================== ADD/UPDATE DOCTOR NOTES ====================
  Future<AppointmentSchedule?> addDoctorNotes(
    int appointmentId,
    String notes,
  ) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConstants.appointmentsDetail}/$appointmentId${ApiConstants.appointmentDoctorNotesSuffix}',
        data: {'doctor_notes': notes},
      );

      if (response.statusCode == 200) {
        return AppointmentSchedule.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to add doctor notes.',
      );
      debugPrint(
        '[APPOINTMENT] Error adding doctor notes: ${apiException.message}',
      );
      return null;
    } catch (e) {
      debugPrint('[APPOINTMENT] Error adding doctor notes: $e');
      return null;
    }
  }

  // ==================== MARK PAYMENT AS PAID (Patient) ====================
  Future<AppointmentSchedule?> markPaymentAsPaid(int appointmentId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.appointmentsDetail}/$appointmentId${ApiConstants.appointmentPaymentMarkPaidSuffix}',
        data: {},
      );

      if (response.statusCode == 200) {
        return AppointmentSchedule.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to mark payment as paid.',
      );
      debugPrint(
        '[APPOINTMENT] Error marking payment as paid: ${apiException.message}',
      );
      return null;
    } catch (e) {
      debugPrint('[APPOINTMENT] Error marking payment as paid: $e');
      return null;
    }
  }

  // ==================== GET FILTERED APPOINTMENT COUNTS ====================
  Future<({int upcomingConfirmedPaid, int completed, int totalFiltered})>
  getFilteredAppointmentCounts() async {
    try {
      final allAppointments = await getAppointments(pageSize: 200);

      final upcomingConfirmedPaid = allAppointments
          .where(
            (a) =>
                a.status == AppointmentStatus.confirmed &&
                a.payment?.status == AppointmentPaymentStatus.confirmed,
          )
          .length;

      final completed = allAppointments
          .where((a) => a.status == AppointmentStatus.completed)
          .length;

      return (
        upcomingConfirmedPaid: upcomingConfirmedPaid,
        completed: completed,
        totalFiltered: upcomingConfirmedPaid + completed,
      );
    } catch (e) {
      debugPrint('[APPOINTMENT] Error getting filtered counts: $e');
      return (upcomingConfirmedPaid: 0, completed: 0, totalFiltered: 0);
    }
  }
}

class AppointmentListResult {
  final List<AppointmentSchedule> appointments;
  final int count;
  final String? next;
  final String? previous;

  AppointmentListResult({
    required this.appointments,
    required this.count,
    this.next,
    this.previous,
  });

  bool get hasNext => next != null;
  bool get hasPrevious => previous != null;
}
