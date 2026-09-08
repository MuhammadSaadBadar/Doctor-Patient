class NearbyHospital {
  final String placeId;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
  final double? rating;
  final bool? isOpenNow;

  const NearbyHospital({
    required this.placeId,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    this.rating,
    this.isOpenNow,
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
}
