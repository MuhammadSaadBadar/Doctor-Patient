// lib/patient/features/ai_assistant/models/paginated_chat_session_list.dart

import 'package:doctor/patient/features/ai_assistant/models/chat_session.dart';

class PaginatedChatSessionList {
  final int count;
  final String? next;
  final String? previous;
  final List<ChatSession> results;

  PaginatedChatSessionList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedChatSessionList.fromJson(Map<String, dynamic> json) {
    final resultsList = (json['results'] as List<dynamic>? ?? [])
        .map((e) => ChatSession.fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedChatSessionList(
      count: json['count'] as int? ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: resultsList,
    );
  }

  bool get hasNext => next != null;
  bool get hasPrevious => previous != null;
  bool get isEmpty => results.isEmpty;
  bool get isNotEmpty => results.isNotEmpty;
}
