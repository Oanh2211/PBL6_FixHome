class TechnicianChatMessageModel {
  final int id;
  final int orderId;
  final int senderAccountId;
  final String messageType;
  final String content;
  final int? mediaId;
  final String clientMessageId;
  final DateTime? sentAt;
  final DateTime? readAt;

  const TechnicianChatMessageModel({
    required this.id,
    required this.orderId,
    required this.senderAccountId,
    required this.messageType,
    required this.content,
    this.mediaId,
    required this.clientMessageId,
    this.sentAt,
    this.readAt,
  });

  factory TechnicianChatMessageModel.fromJson(Map<String, dynamic> json) {
    return TechnicianChatMessageModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      orderId: (json['order_id'] as num?)?.toInt() ?? 0,
      senderAccountId: (json['sender_account_id'] as num?)?.toInt() ?? 0,
      messageType: json['message_type']?.toString() ?? 'TEXT',
      content: json['content']?.toString() ?? '',
      mediaId: (json['media_id'] as num?)?.toInt(),
      clientMessageId: json['client_message_id']?.toString() ?? '',
      sentAt: DateTime.tryParse(json['sent_at']?.toString() ?? ''),
      readAt: DateTime.tryParse(json['read_at']?.toString() ?? ''),
    );
  }
}

class TechnicianChatMessagePage {
  final List<TechnicianChatMessageModel> messages;
  final bool hasMore;

  const TechnicianChatMessagePage({
    required this.messages,
    required this.hasMore,
  });
}
