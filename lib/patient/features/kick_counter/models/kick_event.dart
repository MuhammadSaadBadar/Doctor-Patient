// lib/patient/features/kick_counter/models/kick_event.dart

class KickEvent {
  final int id;
  final DateTime tappedAt;

  KickEvent({required this.id, required this.tappedAt});

  factory KickEvent.fromJson(Map<String, dynamic> json) {
    return KickEvent(
      id: json['id'] ?? 0,
      tappedAt: DateTime.tryParse(json['tapped_at'] ?? '') ?? DateTime.now(),
    );
  }

  String get timeLabel {
    final hour = tappedAt.hour > 12
        ? tappedAt.hour - 12
        : (tappedAt.hour == 0 ? 12 : tappedAt.hour);
    final minute = tappedAt.minute.toString().padLeft(2, '0');
    final amPm = tappedAt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $amPm';
  }
}
