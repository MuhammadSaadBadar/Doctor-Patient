import 'package:flutter/material.dart';

class PatientProfile {
  final DateTime? dateOfBirth;
  final DateTime? lmpDate;
  final DateTime? eddDate;
  final String? bloodGroup;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? address;
  final bool profileComplete;

  PatientProfile({
    this.dateOfBirth,
    this.lmpDate,
    this.eddDate,
    this.bloodGroup,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.address,
    required this.profileComplete,
  });

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      lmpDate: json['lmp_date'] != null
          ? DateTime.parse(json['lmp_date'] as String)
          : null,
      eddDate: json['edd_date'] != null
          ? DateTime.parse(json['edd_date'] as String)
          : null,
      bloodGroup: json['blood_group'] as String?,
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      address: json['address'] as String?,
      profileComplete: json['profile_complete'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth!.toIso8601String().split('T')[0],
      if (lmpDate != null) 'lmp_date': lmpDate!.toIso8601String().split('T')[0],
      if (eddDate != null) 'edd_date': eddDate!.toIso8601String().split('T')[0],
      if (bloodGroup != null && bloodGroup!.isNotEmpty) 'blood_group': bloodGroup,
      if (emergencyContactName != null && emergencyContactName!.isNotEmpty)
        'emergency_contact_name': emergencyContactName,
      if (emergencyContactPhone != null && emergencyContactPhone!.isNotEmpty)
        'emergency_contact_phone': emergencyContactPhone,
      if (address != null && address!.isNotEmpty) 'address': address,
      'profile_complete': profileComplete,
    };
  }

  PatientProfile copyWith({
    DateTime? dateOfBirth,
    DateTime? lmpDate,
    DateTime? eddDate,
    String? bloodGroup,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? address,
    bool? profileComplete,
  }) {
    return PatientProfile(
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      lmpDate: lmpDate ?? this.lmpDate,
      eddDate: eddDate ?? this.eddDate,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      address: address ?? this.address,
      profileComplete: profileComplete ?? this.profileComplete,
    );
  }

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  String? get pregnancyWeek {
    if (lmpDate == null) return null;
    final now = DateTime.now();
    final diff = now.difference(lmpDate!);
    final weeks = (diff.inDays / 7).floor();
    return 'Week $weeks';
  }

  String? get formattedLmpDate {
    if (lmpDate == null) return null;
    return '${lmpDate!.day}/${lmpDate!.month}/${lmpDate!.year}';
  }

  String? get formattedEddDate {
    if (eddDate == null) return null;
    return '${eddDate!.day}/${eddDate!.month}/${eddDate!.year}';
  }

  String get bloodGroupDisplay => bloodGroup ?? 'Not set';

  String get emergencyContactDisplay {
    final parts = <String>[];
    if (emergencyContactName != null && emergencyContactName!.isNotEmpty) {
      parts.add(emergencyContactName!);
    }
    if (emergencyContactPhone != null && emergencyContactPhone!.isNotEmpty) {
      parts.add(emergencyContactPhone!);
    }
    return parts.isEmpty ? 'Not set' : parts.join(' - ');
  }

  String get addressDisplay => address ?? 'Not set';

  bool get hasCompleteProfile => profileComplete;
}

class UserProfile {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final bool isEmailVerified;
  final String role;
  final DateTime dateJoined;
  final String? profilePictureUrl;

  UserProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.isEmailVerified,
    required this.role,
    required this.dateJoined,
    this.profilePictureUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'].toString(),
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String?,
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      role: json['role'] as String? ?? 'patient',
      dateJoined: json['date_joined'] != null
          ? DateTime.parse(json['date_joined'] as String)
          : DateTime.now(),
      profilePictureUrl: json['profile_picture_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'is_email_verified': isEmailVerified,
      'role': role,
      'date_joined': dateJoined.toIso8601String(),
      'profile_picture_url': profilePictureUrl,
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    bool? isEmailVerified,
    String? role,
    DateTime? dateJoined,
    String? profilePictureUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      role: role ?? this.role,
      dateJoined: dateJoined ?? this.dateJoined,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }
}

class PatientProfileData {
  final UserProfile user;
  final PatientProfile? patientProfile;

  PatientProfileData({
    required this.user,
    this.patientProfile,
  });

  factory PatientProfileData.fromJson(Map<String, dynamic> json) {
    return PatientProfileData(
      user: UserProfile.fromJson(json),
      patientProfile: json['patient_profile'] != null
          ? PatientProfile.fromJson(json['patient_profile'] as Map<String, dynamic>)
          : null,
    );
  }

  PatientProfileData copyWith({
    UserProfile? user,
    PatientProfile? patientProfile,
  }) {
    return PatientProfileData(
      user: user ?? this.user,
      patientProfile: patientProfile ?? this.patientProfile,
    );
  }
}