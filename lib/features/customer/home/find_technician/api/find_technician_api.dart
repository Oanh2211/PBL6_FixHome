import 'package:dio/dio.dart';
import 'package:fixhome/common/network/dio_client.dart';
import 'package:fixhome/features/customer/home/find_technician/model/quote_models.dart';
import 'package:fixhome/features/customer/home/find_technician/model/repair_order_model.dart';

class FindTechnicianApi {
  final Dio _dio = DioClient.instance;

  /// 1. GET /repair-orders/{orderId}
  Future<RepairOrderModel> getOrderDetail(int orderId) async {
    final res = await _dio.get('/repair-orders/$orderId');
    return RepairOrderModel.fromJson(res.data);
  }

  /// 2. POST /repair-orders/{orderId}/cancel
  Future<RepairOrderModel> cancelOrder(
    int orderId, {
    required String reason,
  }) async {
    final res = await _dio.post(
      '/repair-orders/$orderId/cancel',
      data: {'reason': reason},
    );
    return RepairOrderModel.fromJson(res.data);
  }

  /// 3. GET /repair-orders/{orderId}/quotes
  Future<QuotePageResponse> getOrderQuotes(
    int orderId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final res = await _dio.get(
      '/repair-orders/$orderId/quotes',
      queryParameters: {'page': page, 'page_size': pageSize},
    );
    return QuotePageResponse.fromJson(res.data);
  }

  /// 4. GET /repair-orders/{orderId}/quotes/{quoteId}
  Future<TechnicianQuoteModel> getQuoteDetail(int orderId, int quoteId) async {
    final res = await _dio.get('/repair-orders/$orderId/quotes/$quoteId');
    return TechnicianQuoteModel.fromJson(res.data);
  }

  /// 5. GET /repair-orders/{orderId}/quotes/{quoteId}/vouchers
  Future<List<ApplicableVoucherModel>> getApplicableVouchers(
    int orderId,
    int quoteId,
  ) async {
    final res = await _dio.get(
      '/repair-orders/$orderId/quotes/$quoteId/vouchers',
    );
    final list = res.data as List<dynamic>;
    return list.map((e) => ApplicableVoucherModel.fromJson(e)).toList();
  }

  /// 6. PUT /repair-orders/{orderId}/quotes/{quoteId}/voucher
  Future<TechnicianQuoteModel> updateQuoteVoucher(
    int orderId,
    int quoteId, {
    String? voucherCode,
  }) async {
    final res = await _dio.put(
      '/repair-orders/$orderId/quotes/$quoteId/voucher',
      data: {'voucher_code': voucherCode},
    );
    return TechnicianQuoteModel.fromJson(res.data);
  }

  /// 7. POST /repair-orders/{orderId}/quotes/{quoteId}/select
  Future<SelectQuoteResponse> selectQuote(int orderId, int quoteId) async {
    final res = await _dio.post(
      '/repair-orders/$orderId/quotes/$quoteId/select',
    );
    return SelectQuoteResponse.fromJson(res.data);
  }
}
