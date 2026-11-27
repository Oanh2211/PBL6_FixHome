import 'package:fixhome/common/network/dio_client.dart';

import '../model/technician_chat_message_model.dart';

class TechnicianChatApiService {
  final _dio = DioClient.instance;

  Future<int> getCurrentAccountId() async {
    final response = await _dio.get('/me');
    final data = Map<String, dynamic>.from(response.data as Map);
    return (data['id'] as num).toInt();
  }

  Future<TechnicianChatMessagePage> getMessages(
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
    final rawMessages = data is Map ? data['messages'] : data;
    final messages = rawMessages is List
        ? rawMessages
              .map(
                (message) => TechnicianChatMessageModel.fromJson(
                  Map<String, dynamic>.from(message as Map),
                ),
              )
              .toList()
        : <TechnicianChatMessageModel>[];

    messages.sort(compareTechnicianChatMessages);
    return TechnicianChatMessagePage(
      messages: messages,
      hasMore: data is Map && data['has_more'] == true,
    );
  }

  Future<TechnicianChatMessageModel> sendMessage({
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
    return TechnicianChatMessageModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}

int compareTechnicianChatMessages(
  TechnicianChatMessageModel a,
  TechnicianChatMessageModel b,
) {
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
