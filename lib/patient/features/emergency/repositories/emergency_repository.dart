import 'dart:convert';

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

  // Multiple Overpass mirrors — tried in order on failure.
  // NOTE: On Flutter Web, only GET requests with no custom headers are CORS
  // "simple requests" (no preflight). We therefore use GET + query param.
  // overpass.private.coffee is listed first because it explicitly allows CORS.
  static const List<String> _overpassMirrors = [
    'https://overpass.private.coffee/api/interpreter',
    'https://overpass-api.de/api/interpreter',
    'https://lz4.overpass-api.de/api/interpreter',
    'https://z.overpass-api.de/api/interpreter',
  ];

  Future<({List<NearbyHospital> hospitals, bool hasNext})> getNearbyHospitals({
    required double latitude,
    required double longitude,
    int radius = 15000,
    int page = 1,
  }) async {
    final query = '''
[out:json][timeout:25];
(
  node["amenity"="hospital"](around:$radius,$latitude,$longitude);
  way["amenity"="hospital"](around:$radius,$latitude,$longitude);
  node["amenity"="clinic"](around:$radius,$latitude,$longitude);
  way["amenity"="clinic"](around:$radius,$latitude,$longitude);
);
out center tags;
''';

    for (final mirror in _overpassMirrors) {
      try {
        debugPrint('[EMERGENCY] Trying Overpass mirror: $mirror');
        // Use GET + query parameter so the browser sends a CORS "simple
        // request" (no preflight).  Custom headers such as User-Agent and
        // the sendTimeout option both force an OPTIONS preflight that most
        // Overpass servers reject, causing the 504 errors seen on web.
        final response = await Dio().get(
          mirror,
          queryParameters: {'data': query},
          options: Options(
            // No custom headers — keep the request CORS-simple.
            responseType: ResponseType.plain,
            receiveTimeout: const Duration(seconds: 30),
          ),
        );

        if (response.statusCode != 200) {
          debugPrint('[EMERGENCY] Mirror $mirror returned ${response.statusCode}, trying next...');
          continue;
        }

        final raw = response.data;
        final Map<String, dynamic> data = raw is String
            ? json.decode(raw) as Map<String, dynamic>
            : raw as Map<String, dynamic>;

        final elements = (data['elements'] as List<dynamic>? ?? []);

        final hospitals = elements.map<NearbyHospital>((el) {
          final tags = (el['tags'] as Map<String, dynamic>? ?? {});
          final lat = (el['lat'] ?? el['center']?['lat']) as num?;
          final lon = (el['lon'] ?? el['center']?['lon']) as num?;

          final name = (tags['name'] as String?)?.trim();
          final street = (tags['addr:street'] as String?)?.trim();
          final houseNo = (tags['addr:housenumber'] as String?)?.trim();
          final city = (tags['addr:city'] as String?)?.trim();

          final addressParts = <String>[
            if (houseNo != null && street != null) '$houseNo $street',
            if (street != null && houseNo == null) street,
            if (city != null) city,
          ];

          return NearbyHospital(
            placeId: 'osm_${el['type']}_${el['id']}',
            name: name?.isNotEmpty == true ? name! : 'Hospital',
            address: addressParts.isNotEmpty
                ? addressParts.join(', ')
                : 'Address unavailable',
            latitude: lat?.toDouble(),
            longitude: lon?.toDouble(),
            rating: null,
            isOpenNow: null,
          );
        }).toList();

        debugPrint('[EMERGENCY] Loaded ${hospitals.length} hospitals from $mirror');
        return (hospitals: hospitals, hasNext: false);
      } on DioException catch (e) {
        debugPrint('[EMERGENCY] Overpass mirror $mirror error: ${e.message}');
        // Try next mirror
        continue;
      } catch (e) {
        debugPrint('[EMERGENCY] Overpass parse error on $mirror: $e');
        continue;
      }
    }

    // All mirrors failed — throw exception to trigger proper error handling
    debugPrint('[EMERGENCY] All Overpass mirrors failed.');
    throw Exception('All hospital API mirrors are currently unreachable.');
  }
}

