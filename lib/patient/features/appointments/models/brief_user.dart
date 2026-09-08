// lib/patient/features/appointments/models/brief_user.dart

import 'package:doctor/core/constants/api_constants.dart';

class BriefUser {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? profilePictureUrl;

  BriefUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profilePictureUrl,
  });

  factory BriefUser.fromJson(Map<String, dynamic> json) {
    return BriefUser(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      profilePictureUrl: json['profile_picture_url'] as String?,
    );
  }

  String get fullName => '$firstName $lastName';

  String? get imageUrl {
    if (profilePictureUrl?.trim().isNotEmpty == true) {
      return profilePictureUrl;
    }
    if (id <= 0) return null;
    return '${ApiConstants.baseUrl}${ApiConstants.apiPrefix}/accounts/doctors/$id/profile-picture/';
  }

  String get initials {
    if (firstName.isEmpty || lastName.isEmpty) return 'DR';
    return '${firstName[0]}${lastName[0]}'.toUpperCase();
  }
}
