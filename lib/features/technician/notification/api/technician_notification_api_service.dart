import 'package:dio/dio.dart';
import 'package:fixhome/common/network/dio_client.dart';
import 'package:fixhome/features/technician/notification/model/technician_notification_model.dart';

class TechnicianNotificationApiService {
  final Dio _dio = DioClient.instance;

  /// GET /notifications
  Future<TechnicianNotificationPageResponse> getNotifications({
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
      return TechnicianNotificationPageResponse.fromJson(data);
    }

    if (data is List) {
      final items = data
          .whereType<Map<String, dynamic>>()
          .map(TechnicianNotificationModel.fromJson)
          .toList();
      return TechnicianNotificationPageResponse(
        content: items,
        page: page,
        pageSize: pageSize,
        totalElements: items.length,
        totalPages: 1,
        isFirst: true,
        isLast: true,
      );
    }

    return const TechnicianNotificationPageResponse(
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
  Future<TechnicianNotificationModel> markAsRead(int notificationId) async {
    final response = await _dio.patch('/notifications/$notificationId/read');
    if (response.data is Map<String, dynamic>) {
      return TechnicianNotificationModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    }
    return TechnicianNotificationModel(
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
