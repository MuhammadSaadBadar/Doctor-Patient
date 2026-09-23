// lib/patient/features/emergency/models/nearby_hospital.dart
import 'package:latlong2/latlong.dart';

class NearbyHospital {
  final String placeId;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
  final double? rating;
  final bool? isOpenNow;

  /// Computed at runtime (not from API) — distance in meters from user.
  double? distanceMeters;

  NearbyHospital({
    required this.placeId,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    this.rating,
    this.isOpenNow,
    this.distanceMeters,
  });

  factory NearbyHospital.fromJson(Map<String, dynamic> json) {
    return NearbyHospital(
      placeId: json['place_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown hospital',
      address: json['address'] as String? ?? 'Address unavailable',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      isOpenNow: json['is_open_now'] as bool?,
    );
  }

  /// Formatted distance string (e.g. "1.2 km" or "850 m").
  String get distanceLabel {
    final m = distanceMeters;
    if (m == null) return '';
    if (m < 1000) return '${m.round()} m';
    return '${(m / 1000).toStringAsFixed(1)} km';
  }
}
