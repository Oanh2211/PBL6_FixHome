import 'package:dio/dio.dart';
import 'package:fixhome/common/network/dio_client.dart';
import 'package:fixhome/features/customer/notification/model/notification_model.dart';

class NotificationApiService {
  final Dio _dio = DioClient.instance;

  /// GET /notifications
  Future<NotificationPageResponse> getNotifications({
    bool? isRead,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    if (isRead != null) {
      queryParams['is_read'] = isRead;
    }

    final response = await _dio.get(
      '/notifications',
      queryParameters: queryParams,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return NotificationPageResponse.fromJson(data);
    }

    if (data is List) {
      final items = data
          .whereType<Map<String, dynamic>>()
          .map(NotificationModel.fromJson)
          .toList();
      return NotificationPageResponse(
        content: items,
        page: page,
        pageSize: pageSize,
        totalElements: items.length,
        totalPages: 1,
        isFirst: true,
        isLast: true,
      );
    }

    return const NotificationPageResponse(
      content: [],
      page: 1,
      pageSize: 20,
      totalElements: 0,
      totalPages: 1,
      isFirst: true,
      isLast: true,
    );
  }

  /// PATCH /notifications/{notificationId}/read
  Future<NotificationModel> markAsRead(int notificationId) async {
    final response = await _dio.patch('/notifications/$notificationId/read');
    if (response.data is Map<String, dynamic>) {
      return NotificationModel.fromJson(response.data as Map<String, dynamic>);
    }
    return NotificationModel(
      id: notificationId,
      accountId: 0,
      type: '',
      title: '',
      body: '',
      referenceType: '',
      isRead: true,
    );
  }

  /// PATCH /notifications/read-all
  Future<void> markAllAsRead() async {
    await _dio.patch('/notifications/read-all');
  }
}
