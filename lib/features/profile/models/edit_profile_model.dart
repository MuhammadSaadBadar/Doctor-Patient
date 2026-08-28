// lib/features/profile/models/edit_profile_models.dart

/// Doctor Profile update request
class DoctorProfileUpdateRequest {
  final String? specialization;
  final String? licenseNumber;
  final int? yearsOfExperience;
  final String? bio;
  final bool? isAcceptingPatients;
  final String? city;
  final String? area;
  final double? latitude;
  final double? longitude;
  final double? consultationFee;

  DoctorProfileUpdateRequest({
    this.specialization,
    this.licenseNumber,
    this.yearsOfExperience,
    this.bio,
    this.isAcceptingPatients,
    this.city,
    this.area,
    this.latitude,
    this.longitude,
    this.consultationFee,
  });

  Map<String, dynamic> toJson() {
    return {
      if (specialization != null) 'specialization': specialization,
      if (licenseNumber != null) 'license_number': licenseNumber,
      if (yearsOfExperience != null) 'years_of_experience': yearsOfExperience,
      if (bio != null) 'bio': bio,
      if (isAcceptingPatients != null)
        'is_accepting_patients': isAcceptingPatients,
      if (city != null) 'city': city,
      if (area != null) 'area': area,
      if (latitude != null) 'latitude': latitude?.toString(),
      if (longitude != null) 'longitude': longitude?.toString(),
      if (consultationFee != null)
        'consultation_fee': consultationFee == consultationFee!.roundToDouble() 
            ? consultationFee!.toInt().toString() 
            : consultationFee?.toStringAsFixed(2),
    };
  }
}

/// User profile update request (name, phone)
class UserProfileUpdateRequest {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;

  UserProfileUpdateRequest({this.firstName, this.lastName, this.phoneNumber});

  Map<String, dynamic> toJson() {
    return {
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
    };
  }
}

/// Combined profile response
class DoctorProfileResponse {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final bool isEmailVerified;
  final String role;
  final DateTime dateJoined;
  final DoctorProfileData? doctorProfile;

  DoctorProfileResponse({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.isEmailVerified,
    required this.role,
    required this.dateJoined,
    this.doctorProfile,
  });

  factory DoctorProfileResponse.fromJson(Map<String, dynamic> json) {
    return DoctorProfileResponse(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      role: json['role'] ?? 'doctor',
      dateJoined:
          DateTime.tryParse(json['date_joined'] ?? '') ?? DateTime.now(),
      doctorProfile: json['doctor_profile'] != null
          ? DoctorProfileData.fromJson(
              json['doctor_profile'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class DoctorProfileData {
  final String? specialization;
  final String? licenseNumber;
  final int? yearsOfExperience;
  final String? bio;
  final bool isAcceptingPatients;
  final String? city;
  final String? area;
  final double? latitude;
  final double? longitude;
  final double? consultationFee;

  DoctorProfileData({
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
  });

  factory DoctorProfileData.fromJson(Map<String, dynamic> json) {
    return DoctorProfileData(
      specialization: json['specialization'],
      licenseNumber: json['license_number'],
      yearsOfExperience: json['years_of_experience'],
      bio: json['bio'],
      isAcceptingPatients: json['is_accepting_patients'] as bool? ?? false,
      city: json['city'],
      area: json['area'],
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      consultationFee: json['consultation_fee'] != null
          ? double.tryParse(json['consultation_fee'].toString())
          : null,
    );
  }
}
