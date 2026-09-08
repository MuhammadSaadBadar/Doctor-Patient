import 'package:dio/dio.dart';
import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/network/api_error_mapper.dart';
import 'package:doctor/patient/features/emergency/models/nearby_hospital.dart';
import 'package:doctor/patient/features/emergency/models/patient_sos_event.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class EmergencyRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<({List<PatientSosEvent> events, bool hasNext})> getSosEvents({
    int page = 1,
    int pageSize = 20,
    String? status,
  }) async {
    try {
      final query = <String, dynamic>{'page': page, 'page_size': pageSize};
      if (status != null) query['status'] = status;
      final response = await _apiClient.get(
        ApiConstants.emergencySos,
        queryParameters: query,
      );
      if (response.statusCode != 200)
        return (events: <PatientSosEvent>[], hasNext: false);
      final data = response.data as Map<String, dynamic>;
      final events = (data['results'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(PatientSosEvent.fromJson)
          .toList();
      return (events: events, hasNext: data['next'] != null);
    } on DioException catch (e) {
      throw ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load SOS records.',
      );
    }
  }

  Future<PatientSosEvent?> createSos({
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{
        if (latitude != null) 'latitude': _formatCoordinate(latitude),
        if (longitude != null) 'longitude': _formatCoordinate(longitude),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      };
      final response = await _apiClient.post(
        ApiConstants.emergencySos,
        data: data,
      );
      if (response.statusCode == 201) {
        return PatientSosEvent.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      throw ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to send SOS.',
      );
    }
  }

  String _formatCoordinate(double coordinate) {
    return coordinate.toStringAsFixed(6);
  }

  Future<PatientSosEvent?> resolveSos({
    required int id,
    required String status,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.emergencySosDetail}/$id${ApiConstants.emergencySosResolveSuffix}',
        data: {'status': status},
      );
      if (response.statusCode == 200) {
        return PatientSosEvent.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      throw ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to update SOS.',
      );
    }
  }

  Future<({List<NearbyHospital> hospitals, bool hasNext})> getNearbyHospitals({
    required double latitude,
    required double longitude,
    int radius = 5000,
    int page = 1,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.hospitalsNearby,
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
          'radius': radius,
          'page': page,
          'page_size': 20,
        },
      );
      if (response.statusCode != 200)
        return (hospitals: <NearbyHospital>[], hasNext: false);
      final data = response.data as Map<String, dynamic>;
      final hospitals = (data['results'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(NearbyHospital.fromJson)
          .toList();
      return (hospitals: hospitals, hasNext: data['next'] != null);
    } on DioException catch (e) {
      debugPrint('[EMERGENCY] Hospital API error: ${e.message}');
      throw ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Hospital search is unavailable.',
      );
    }
  }
}
