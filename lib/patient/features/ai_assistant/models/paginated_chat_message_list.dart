// lib/patient/features/ai_assistant/models/paginated_chat_message_list.dart

import 'package:doctor/patient/features/ai_assistant/models/chat_message.dart';

class PaginatedChatMessageList {
  final int count;
  final String? next;
  final String? previous;
  final List<ChatMessage> results;

  PaginatedChatMessageList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedChatMessageList.fromJson(Map<String, dynamic> json) {
    final resultsList = (json['results'] as List<dynamic>? ?? [])
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedChatMessageList(
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
