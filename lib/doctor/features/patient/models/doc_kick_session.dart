class KickSession {
  final int id;
  final int patientId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int kickCount;
  final DateTime logDate;
  final List<KickEvent> events;
  final String? notes;

  KickSession({
    required this.id,
    required this.patientId,
    required this.startedAt,
    this.endedAt,
    required this.kickCount,
    required this.logDate,
    this.events = const [],
    this.notes,
  });

  // Computed properties
  String get displayTime {
    final start = startedAt.toLocal();
    final end = endedAt?.toLocal();

    if (end == null) {
      return 'Started at ${_formatTime(start)}';
    }

    return '${_formatTime(start)} - ${_formatTime(end)}';
  }

  String get displayDuration {
    if (endedAt == null) return 'In progress';

    final duration = endedAt!.difference(startedAt);
    final minutes = duration.inMinutes;

    if (minutes < 60) {
      return '$minutes min';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '$hours h ${remainingMinutes}min';
  }

  int get durationMinutes {
    if (endedAt == null) return 0;
    return endedAt!.difference(startedAt).inMinutes;
  }

  String get displayDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(logDate.year, logDate.month, logDate.day);

    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';

    // Check if it's within the last 7 days
    if (date.isAfter(now.subtract(const Duration(days: 7)))) {
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[date.weekday - 1];
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  String get displayGroup {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(logDate.year, logDate.month, logDate.day);

    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';
    return 'Older';
  }

  static String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12
        ? hour - 12
        : hour == 0
        ? 12
        : hour;
    return '$displayHour:$minute $ampm';
  }

  factory KickSession.fromJson(Map<String, dynamic> json) {
    return KickSession(
      id: json['id'],
      patientId: json['patient']['id'],
      startedAt: DateTime.parse(json['started_at']),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'])
          : null,
      kickCount: json['kick_count'] ?? 0,
      logDate: DateTime.parse('${json['log_date']} 00:00:00'),
      events: (json['events'] as List<dynamic>? ?? [])
          .map((e) => KickEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'],
    );
  }
}

class KickEvent {
  final int id;
  final DateTime tappedAt;

  KickEvent({required this.id, required this.tappedAt});

  factory KickEvent.fromJson(Map<String, dynamic> json) {
    return KickEvent(
      id: json['id'],
      tappedAt: DateTime.parse(json['tapped_at']),
    );
  }
}
