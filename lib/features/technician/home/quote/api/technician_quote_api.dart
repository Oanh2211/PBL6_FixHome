import 'package:dio/dio.dart';
import 'package:fixhome/common/network/dio_client.dart';

import '../model/technician_quote_model.dart';

class TechnicianQuoteApi {
  final Dio _dio;

  TechnicianQuoteApi({Dio? dio}) : _dio = dio ?? DioClient.instance;

  // GET /technician/quotes
  Future<TechnicianQuoteListResponse> getQuotes({
    String? status,
    String? requestedTimeType,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/technician/quotes',
        queryParameters: {
          if (status != null && status.isNotEmpty) 'status': status,
          if (requestedTimeType != null && requestedTimeType.isNotEmpty)
            'requested_time_type': requestedTimeType,
          'page': page,
          'page_size': pageSize,
        },
      );

      return TechnicianQuoteListResponse.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException {
      // Giữ nguyên DioException để Cubit kiểm tra statusCode
      // và response.data['code'].
      rethrow;
    }
  }

  // GET /technician/quotes/{quoteId}
  Future<TechnicianQuoteDetailModel> getQuoteDetail(int quoteId) async {
    try {
      final response = await _dio.get('/technician/quotes/$quoteId');

      return TechnicianQuoteDetailModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException {
      rethrow;
    }
  }

  String _handleError(DioException e) {
    final data = e.response?.data;

    if (data is Map) {
      return data['message']?.toString() ??
          data['detail']?.toString() ??
          data['error']?.toString() ??
          'Đã xảy ra lỗi khi kết nối máy chủ.';
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Kết nối máy chủ quá thời gian cho phép.';
      case DioExceptionType.connectionError:
        return 'Không thể kết nối máy chủ. Vui lòng kiểm tra Internet.';
      default:
        return e.message ?? 'Đã xảy ra lỗi không xác định.';
    }
  }
}
