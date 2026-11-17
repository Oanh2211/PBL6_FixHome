import 'dart:convert';

import 'package:fixhome/features/technician/home/quote/model/technician_submit_quote_model.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:fixhome/common/network/dio_client.dart';

import '../model/technician_quote_model.dart';

class TechnicianQuoteApi {
  final Dio _dio;

  TechnicianQuoteApi({Dio? dio}) : _dio = dio ?? DioClient.instance;

  Future<Map<String, dynamic>> getMedia(int mediaId) async {
    try {
      debugPrint('========== GET MEDIA ==========');
      debugPrint('BASE URL: ${_dio.options.baseUrl}');
      debugPrint('MEDIA ID: $mediaId');

      final response = await _dio.get('/media/$mediaId');

      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('REAL URL: ${response.realUri}');
      debugPrint('RESPONSE: ${response.data}');

      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      debugPrint('========== MEDIA ERROR ==========');
      debugPrint('REQUEST URL: ${e.requestOptions.uri}');
      debugPrint('REQUEST METHOD: ${e.requestOptions.method}');
      debugPrint('STATUS CODE: ${e.response?.statusCode}');
      debugPrint('RESPONSE BODY: ${e.response?.data}');

      rethrow;
    }
  }

  Future<List<TechnicianQuoteModel>> enrichQuotes(
    List<TechnicianQuoteModel> quotes,
  ) async {
    try {
      final categoryResponse = await _dio.get('/service-categories');
      final categoryRows = _asList(categoryResponse.data);
      final categories = <int, Map<String, dynamic>>{
        for (final row in categoryRows) _asInt(row['id']): row,
      };

      final deviceNames = <int, String>{};
      final categoryIds = quotes.map((q) => q.categoryId).toSet();

      await Future.wait(
        categoryIds.map((categoryId) async {
          try {
            final response = await _dio.get(
              '/service-categories/$categoryId/device-types',
            );
            for (final device in _asList(response.data)) {
              deviceNames[_asInt(device['id'])] =
                  device['name']?.toString() ?? '';
            }
          } catch (e) {
            debugPrint('QUOTE CATALOG DEVICE ERROR [$categoryId]: $e');
          }
        }),
      );

      return quotes
          .map((quote) {
            final category = categories[quote.categoryId];
            return quote.copyWithCatalog(
              categoryName: category?['name']?.toString() ?? '',
              categoryIconUrl: category?['icon_url']?.toString() ?? '',
              deviceName: deviceNames[quote.deviceTypeId] ?? '',
            );
          })
          .toList(growable: false);
    } catch (e) {
      debugPrint('QUOTE CATALOG ERROR: $e');
      return quotes;
    }
  }

  List<Map<String, dynamic>> _asList(dynamic data) {
    final raw = data is List
        ? data
        : (data is Map ? (data['content'] ?? data['data']) : null);
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  int _asInt(dynamic value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

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

      final detail = TechnicianQuoteDetailModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );

      // Lấy tên nghiệp vụ và tên thiết bị từ danh mục.
      final enriched = await enrichQuotes([detail]);

      if (enriched.isEmpty) return detail;

      final quote = enriched.first;

      return TechnicianQuoteDetailModel(
        quoteId: quote.quoteId,
        orderId: quote.orderId,
        orderCode: quote.orderCode,
        status: quote.status,
        requestedTimeType: quote.requestedTimeType,
        scheduledAt: quote.scheduledAt,
        categoryId: quote.categoryId,
        deviceTypeId: quote.deviceTypeId,
        wardCode: quote.wardCode,
        address: quote.address,
        latitude: quote.latitude,
        longitude: quote.longitude,
        distanceKm: quote.distanceKm,
        inviteRound: quote.inviteRound,
        issueDescription: quote.issueDescription,
        invitedAt: quote.invitedAt,
        expiresAt: quote.expiresAt,
        categoryName: quote.categoryName,
        categoryIconUrl: quote.categoryIconUrl,
        deviceName: quote.deviceName,
        mediaIds: quote.mediaIds,
        issueMedia: detail.issueMedia,
        customerNote: detail.customerNote,
        contactName: detail.contactName,
        estimatedMinAmount: detail.estimatedMinAmount,
        estimatedMaxAmount: detail.estimatedMaxAmount,
        discountAmount: detail.discountAmount,
        warrantyDurationDays: detail.warrantyDurationDays,
        note: detail.note,
        respondedAt: detail.respondedAt,
        items: detail.items,
      );
    } on DioException {
      rethrow;
    }
  }

  // POST /technician/quotes/{quoteId}/acknowledge
  // Kỹ thuật viên chấp nhận lời mời báo giá.
  Future<void> acknowledgeQuote(int quoteId) async {
    try {
      await _dio.post('/technician/quotes/$quoteId/acknowledge');
    } on DioException {
      rethrow;
    }
  }

  // POST /technician/quotes/{quoteId}/decline
  // Kỹ thuật viên từ chối lời mời báo giá.
  Future<void> declineQuote(int quoteId) async {
    try {
      await _dio.post('/technician/quotes/$quoteId/decline');
    } on DioException {
      rethrow;
    }
  }

  Future<void> submitQuote({
    required int quoteId,
    required TechnicianSubmitQuoteRequestModel request,
  }) async {
    final payload = request.toJson();
    debugPrint('========== SUBMIT QUOTE ==========');
    debugPrint('POST /technician/quotes/$quoteId/submit');
    debugPrint(
      'REQUEST: ${const JsonEncoder.withIndent('  ').convert(payload)}',
    );
    try {
      final response = await _dio.post(
        '/technician/quotes/$quoteId/submit',
        data: payload,
      );
      debugPrint(
        'SUBMIT QUOTE SUCCESS [${response.statusCode}]: ${response.data}',
      );
    } on DioException catch (e) {
      debugPrint('SUBMIT QUOTE FAILED');
      debugPrint('STATUS: ${e.response?.statusCode}');
      debugPrint('RESPONSE: ${e.response?.data}');
      debugPrint(
        'REQUEST OPTIONS: ${e.requestOptions.method} ${e.requestOptions.uri}',
      );
      debugPrint('DIO ERROR: ${e.message}');
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
