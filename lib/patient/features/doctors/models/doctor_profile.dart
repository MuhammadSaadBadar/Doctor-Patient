// lib/patient/features/doctors/models/doctor_profile.dart

class DoctorProfile {
  final String? specialization;
  final String? licenseNumber;
  final int? yearsOfExperience;
  final String? bio;
  final bool isAcceptingPatients;
  final String? city;
  final String? area;
  final double? latitude;
  final double? longitude;
  final String? consultationFee;
  final String? profilePictureUrl;

  DoctorProfile({
    this.specialization,
    this.licenseNumber,
    this.yearsOfExperience,
    this.bio,
    required this.isAcceptingPatients,
    this.city,
    this.area,
    this.latitude,
    this.longitude,
    this.consultationFee,
    this.profilePictureUrl,
  });

  factory DoctorProfile.fromJson(Map<String, dynamic> json) {
    return DoctorProfile(
      specialization: json['specialization'],
      licenseNumber: json['license_number'],
      yearsOfExperience: json['years_of_experience'],
      bio: json['bio'],
      isAcceptingPatients: json['is_accepting_patients'] ?? true,
      city: json['city'],
      area: json['area'],
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      consultationFee: _parseString(json['consultation_fee']),
      profilePictureUrl: json['profile_picture_url'] as String?,
    );
  }

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is num) return value.toString();
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String get formattedFee {
    if (consultationFee == null) return 'Free';
    return 'Rs. ${double.tryParse(consultationFee!)?.toStringAsFixed(0) ?? consultationFee}';
  }

  String get experienceDisplay {
    if (yearsOfExperience == null) return 'N/A';
    return '$yearsOfExperience Years Exp.';
  }

  bool get hasSpecialization =>
      specialization != null && specialization!.isNotEmpty;

  bool get hasLocation => latitude != null && longitude != null;

  /// Returns a clean, comma-separated address string from available fields.
  /// Handles missing parts gracefully (no leading/trailing/duplicate commas).
  String get formattedAddress {
    final parts = <String>[];
    if (area != null && area!.isNotEmpty) parts.add(area!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    return parts.join(', ');
  }

  /// True if at least one address component (area or city) is present.
  bool get hasAddress => (area != null && area!.isNotEmpty) ||
      (city != null && city!.isNotEmpty);
}
