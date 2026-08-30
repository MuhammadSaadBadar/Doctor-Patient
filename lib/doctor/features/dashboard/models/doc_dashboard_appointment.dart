import 'package:doctor/core/constants/color_constants.dart';

class DashboardAppointment {
  final String id;
  final String initials;
  final String name;
  final String type;
  final String icon;
  final String time;
  final String? duration;
  final bool isUpNext;

  DashboardAppointment({
    required this.id,
    required this.initials,
    required this.name,
    required this.type,
    required this.icon,
    required this.time,
    this.duration,
    this.isUpNext = false,
  });

  factory DashboardAppointment.fromJson(Map<String, dynamic> json) {
    final patientName = json['patient']?['first_name'] ?? '';
    final patientLastName = json['patient']?['last_name'] ?? '';
    final fullName = '$patientName $patientLastName'.trim();

    return DashboardAppointment(
      id: json['id']?.toString() ?? '',
      initials: _getInitials(patientName, patientLastName),
      name: fullName.isNotEmpty ? fullName : 'Unknown Patient',
      type: json['appointment_type'] == 'video_consultation'
          ? 'Video Consult'
          : 'In-person',
      icon: json['appointment_type'] == 'video_consultation'
          ? 'videocam'
          : 'person',
      time: _formatTime(json['scheduled_at']),
      duration: json['duration_minutes'] != null
          ? '${json['duration_minutes']} min'
          : null,
      isUpNext: json['is_up_next'] ?? false,
    );
  }

  static String _getInitials(String firstName, String lastName) {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  static String _formatTime(String? dateTimeString) {
    if (dateTimeString == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (e) {
      return 'N/A';
    }
  }
}
