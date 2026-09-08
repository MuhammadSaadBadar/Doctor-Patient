// lib/patient/features/ai_assistant/models/chat_session.dart

class ChatSession {
  final int id;
  final String language;
  final String title;
  final DateTime createdAt;

  ChatSession({
    required this.id,
    required this.language,
    required this.title,
    required this.createdAt,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] ?? 0,
      language: json['language'] ?? 'en',
      title: json['title'] ?? 'New Chat',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'language': language,
      'title': title,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ChatSession copyWith({
    int? id,
    String? language,
    String? title,
    DateTime? createdAt,
  }) {
    return ChatSession(
      id: id ?? this.id,
      language: language ?? this.language,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(createdAt.year, createdAt.month, createdAt.day);

    if (date == today) return 'Today';
    final yesterday = today.subtract(const Duration(days: 1));
    if (date == yesterday) return 'Yesterday';

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[createdAt.month - 1]} ${createdAt.day}, ${createdAt.year}';
  }
}
