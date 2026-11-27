import 'package:fixhome/common/network/dio_client.dart';

import '../model/chat_message_model.dart';

class ChatApiService {
  final _dio = DioClient.instance;

  Future<int> getCurrentAccountId() async {
    final response = await _dio.get('/me');
    final data = Map<String, dynamic>.from(response.data as Map);
    return (data['id'] as num).toInt();
  }

  Future<ChatMessagePage> getMessages(
    int orderId, {
    int? beforeId,
    int pageSize = 30,
  }) async {
    final response = await _dio.get(
      '/orders/$orderId/messages',
      queryParameters: {
        if (beforeId != null) 'before_id': beforeId,
        'page_size': pageSize,
      },
    );

    final data = response.data;
    final rawMessages = data is Map
        ? data['messages']
        : data;
    final messages = rawMessages is List
        ? rawMessages
              .map(
                (message) => ChatMessageModel.fromJson(
                  Map<String, dynamic>.from(message as Map),
                ),
              )
              .toList()
        : <ChatMessageModel>[];

    messages.sort(compareChatMessages);
    return ChatMessagePage(
      messages: messages,
      hasMore: data is Map && data['has_more'] == true,
    );
  }

  Future<ChatMessageModel> sendMessage({
    required int orderId,
    required String content,
    required String clientMessageId,
  }) async {
    final response = await _dio.post(
      '/orders/$orderId/messages',
      data: {
        'client_message_id': clientMessageId,
        'message_type': 'TEXT',
        'content': content,
        'media_id': null,
      },
    );
    return ChatMessageModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

}

int compareChatMessages(ChatMessageModel a, ChatMessageModel b) {
  final aTime = a.sentAt;
  final bTime = b.sentAt;
  if (aTime != null && bTime != null) {
    final timeOrder = aTime.compareTo(bTime);
    if (timeOrder != 0) return timeOrder;
  } else if (aTime != null) {
    return 1;
  } else if (bTime != null) {
    return -1;
  }
  return a.id.compareTo(b.id);
}
