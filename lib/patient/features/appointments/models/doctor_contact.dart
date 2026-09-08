// lib/patient/features/appointments/models/doctor_contact.dart

class DoctorContact {
  final String? phoneNumber;

  DoctorContact({this.phoneNumber});

  factory DoctorContact.fromJson(Map<String, dynamic> json) {
    return DoctorContact(
      phoneNumber: json['phone_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'phone_number': phoneNumber};
  }
}