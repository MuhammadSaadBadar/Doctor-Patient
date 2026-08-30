// lib/features/patient/models/send_message.dart

/// Model for sending a message to a patient
class SendMessageRequest {
  final int patientId;
  final String title;
  final String body;
  final bool isUrgent;

  SendMessageRequest({
    required this.patientId,
    required this.title,
    required this.body,
    this.isUrgent = false,
  });

  Map<String, dynamic> toJson() {
    return {'patient_id': patientId, 'title': title, 'body': body};
  }
}

/// Response model for sent message
class SendMessageResponse {
  final String id;
  final String notificationType;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final bool channelPushSent;
  final bool channelWhatsappSent;
  final DateTime createdAt;

  SendMessageResponse({
    required this.id,
    required this.notificationType,
    required this.title,
    required this.body,
    this.data,
    required this.isRead,
    required this.channelPushSent,
    required this.channelWhatsappSent,
    required this.createdAt,
  });

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    return SendMessageResponse(
      id: json['id'].toString(),
      notificationType: json['notification_type'] ?? 'doctor_message',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['is_read'] as bool? ?? false,
      channelPushSent: json['channel_push_sent'] as bool? ?? false,
      channelWhatsappSent: json['channel_whatsapp_sent'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
