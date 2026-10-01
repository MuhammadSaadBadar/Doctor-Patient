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
  final Dio _overpassClient;

  EmergencyRepository({Dio? overpassClient})
    : _overpassClient = overpassClient ?? Dio();

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

  static const List<String> _overpassMirrors = [
    'https://overpass.private.coffee/api/interpreter',
    'https://overpass-api.de/api/interpreter',
    'https://lz4.overpass-api.de/api/interpreter',
    'https://z.overpass-api.de/api/interpreter',
  ];

  static const int _maxOverpassAttempts = 5;
  static const Duration _overpassConnectTimeout = Duration(seconds: 8);
  static const Duration _overpassSendTimeout = Duration(seconds: 10);
  static const Duration _overpassReceiveTimeout = Duration(seconds: 35);

  Future<({List<NearbyHospital> hospitals, bool hasNext})> getNearbyHospitals({
    required double latitude,
    required double longitude,
    int radius = 5000,
    int page = 1,
  }) async {
    if (!latitude.isFinite ||
        !longitude.isFinite ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      throw const FormatException('Invalid location coordinates.');
    }

    final query =
        '''
[out:json][timeout:15];
(
  nwr["amenity"="hospital"](around:$radius,$latitude,$longitude);
  nwr["amenity"="clinic"](around:$radius,$latitude,$longitude);
);
out center tags qt;
''';

    DioException? lastTransientError;
    for (var attempt = 0; attempt < _maxOverpassAttempts; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(_retryDelay(attempt));
      }

      final mirror = _overpassMirrors[attempt % _overpassMirrors.length];
      try {
        debugPrint(
          '[EMERGENCY] Overpass attempt ${attempt + 1}/$_maxOverpassAttempts',
        );
        final response = await _overpassClient.get(
          mirror,
          queryParameters: {'data': query},
          options: Options(
            responseType: ResponseType.plain,
            headers: {'User-Agent': 'DoctorApp/1.0 (contact@doctorapp.com)'},
            connectTimeout: _overpassConnectTimeout,
            sendTimeout: _overpassSendTimeout,
            receiveTimeout: _overpassReceiveTimeout,
            validateStatus: (status) => status != null,
          ),
        );

        final statusCode = response.statusCode ?? 0;
        if (statusCode != 200) {
          if (_isTransientStatus(statusCode)) {
            debugPrint('[EMERGENCY] Overpass returned $statusCode');
            continue;
          }
          throw FormatException(
            'Overpass request rejected with status $statusCode.',
          );
        }

        final hospitals = _parseOverpassHospitals(response.data);

        debugPrint('[EMERGENCY] Loaded ${hospitals.length} hospitals');
        return (hospitals: hospitals, hasNext: false);
      } on DioException catch (e) {
        if (!_isTransientError(e)) rethrow;
        lastTransientError = e;
        debugPrint('[EMERGENCY] Transient Overpass failure: ${e.type}');
      }
    }

    debugPrint(
      '[EMERGENCY] Overpass unavailable after $_maxOverpassAttempts attempts',
    );
    throw Exception(
      lastTransientError == null
          ? 'Nearby hospitals are temporarily unavailable.'
          : 'Nearby hospitals could not be loaded right now.',
    );
  }

  List<NearbyHospital> _parseOverpassHospitals(dynamic raw) {
    final decoded = raw is String ? json.decode(raw) : raw;
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Unsupported Overpass response.');
    }

    final elements = decoded['elements'];
    if (elements is! List) {
      throw const FormatException('Unsupported Overpass response.');
    }

    return elements.whereType<Map<String, dynamic>>().map((element) {
      final tags = element['tags'] is Map
          ? Map<String, dynamic>.from(element['tags'] as Map)
          : <String, dynamic>{};
      final center = element['center'] is Map
          ? Map<String, dynamic>.from(element['center'] as Map)
          : const <String, dynamic>{};
      final latitude = (element['lat'] ?? center['lat']) as num?;
      final longitude = (element['lon'] ?? center['lon']) as num?;
      final name = (tags['name'] as String?)?.trim();
      final street = (tags['addr:street'] as String?)?.trim();
      final houseNumber = (tags['addr:housenumber'] as String?)?.trim();
      final city = (tags['addr:city'] as String?)?.trim();
      final addressParts = <String>[
        if (houseNumber != null && street != null) '$houseNumber $street',
        if (street != null && houseNumber == null) street,
        if (city != null) city,
      ];

      return NearbyHospital(
        placeId: 'osm_${element['type']}_${element['id']}',
        name: name?.isNotEmpty == true ? name! : 'Hospital',
        address: addressParts.isNotEmpty
            ? addressParts.join(', ')
            : 'Address unavailable',
        latitude: latitude?.toDouble(),
        longitude: longitude?.toDouble(),
        rating: null,
        isOpenNow: null,
      );
    }).toList();
  }

  bool _isTransientStatus(int statusCode) {
    return statusCode == 403 ||
        statusCode == 429 ||
        statusCode == 502 ||
        statusCode == 503 ||
        statusCode == 504;
  }

  bool _isTransientError(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.unknown;
  }

  Duration _retryDelay(int attempt) {
    final seconds = 1 << (attempt - 1);
    return Duration(seconds: seconds > 8 ? 8 : seconds);
  }
}
