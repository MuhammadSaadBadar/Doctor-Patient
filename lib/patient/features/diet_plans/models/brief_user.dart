// lib/patient/features/diet_plans/models/brief_user.dart

class BriefUser {
  final int id;
  final String email;
  final String firstName;
  final String lastName;

  BriefUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  factory BriefUser.fromJson(Map<String, dynamic> json) {
    return BriefUser(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
    );
  }

  String get fullName => '$firstName $lastName';
}
