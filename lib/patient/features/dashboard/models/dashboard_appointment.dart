// lib/patient/features/dashboard/models/dashboard_appointment.dart

class DashboardAppointment {
  final int id;
  final int doctorId;
  final String doctorFirstName;
  final String doctorLastName;
  final String appointmentType;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String status;
  final String? reason;
  final String? specialization;

  DashboardAppointment({
    required this.id,
    required this.doctorId,
    required this.doctorFirstName,
    required this.doctorLastName,
    required this.appointmentType,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.status,
    this.reason,
    this.specialization,
  });

  factory DashboardAppointment.fromJson(Map<String, dynamic> json) {
    final doctor = json['doctor'] as Map<String, dynamic>? ?? {};
    final doctorProfile = json['doctor_profile'] as Map<String, dynamic>? ?? {};

    return DashboardAppointment(
      id: json['id'] ?? 0,
      doctorId: doctor['id'] ?? 0,
      doctorFirstName: doctor['first_name'] ?? '',
      doctorLastName: doctor['last_name'] ?? '',
      appointmentType: json['appointment_type'] ?? 'in_person',
      scheduledAt:
          DateTime.tryParse(json['scheduled_at'] ?? '') ?? DateTime.now(),
      durationMinutes: json['duration_minutes'] ?? 30,
      status: json['status'] ?? 'pending',
      reason: json['reason'],
      specialization: doctorProfile['specialization'],
    );
  }

  String get doctorFullName => '$doctorFirstName $doctorLastName';
  String get typeLabel =>
      appointmentType == 'video_consultation' ? 'Video' : 'In-Person';
  bool get isConfirmed => status == 'confirmed';
  bool get isPending => status == 'pending';
}
