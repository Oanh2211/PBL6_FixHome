import 'package:dio/dio.dart';
import 'package:fixhome/common/network/dio_client.dart';
import 'package:fixhome/features/customer/activity/model/quote_model.dart';
import 'package:fixhome/features/customer/activity/model/repair_order_model.dart';
import 'package:fixhome/features/customer/activity/model/service_catalog_model.dart';

class ActivityApiService {
  final Dio _dio = DioClient.instance;

  // Cache để map tên dịch vụ và tên thiết bị nhanh, tránh gọi thừa request
  final Map<int, ServiceCategoryModel> _categoryCache = {};
  final Map<int, List<DeviceTypeModel>> _deviceTypesCache = {};

  /// 1. GET /repair-orders
  Future<List<RepairOrderModel>> getRepairOrders({
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sort': 'createdAt,desc',
    };
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final response = await _dio.get(
      '/repair-orders',
      queryParameters: queryParams,
    );

    final data = response.data;
    final List<dynamic> content = data is Map<String, dynamic>
        ? (data['content'] ?? [])
        : (data is List ? data : []);

    final orders = content.map((e) => RepairOrderModel.fromJson(e)).toList();

    // Lọc status KHÁC "CANCELLED"
    final validOrders = orders
        .where((order) => order.status.toUpperCase() != 'CANCELLED')
        .toList();

    // Enrich song song: map tên dịch vụ, thiết bị và thông tin KTV/báo giá nếu technician_id != null
    return Future.wait(validOrders.map(_enrichOrder));
  }

  /// 2. GET /repair-orders/{orderId}
  Future<RepairOrderModel> getOrderDetail(int orderId) async {
    final response = await _dio.get('/repair-orders/$orderId');
    final order = RepairOrderModel.fromJson(response.data);
    return _enrichOrder(order);
  }

  /// 3. GET /repair-orders/{orderId}/quotes
  Future<List<QuoteModel>> getOrderQuotes(
    int orderId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      '/repair-orders/$orderId/quotes',
      queryParameters: {'page': page, 'page_size': pageSize},
    );

    final data = response.data;
    final List<dynamic> content = data is Map<String, dynamic>
        ? (data['content'] ?? [])
        : (data is List ? data : []);

    return content.map((e) => QuoteModel.fromJson(e)).toList();
  }

  /// 4. GET /repair-orders/{orderId}/quotes/{quoteId}
  Future<QuoteModel> getQuoteDetail(int orderId, int quoteId) async {
    final response = await _dio.get('/repair-orders/$orderId/quotes/$quoteId');
    return QuoteModel.fromJson(response.data);
  }

  /// 5. GET /service-categories/{id}
  Future<ServiceCategoryModel?> getServiceCategoryById(int id) async {
    if (_categoryCache.containsKey(id)) {
      return _categoryCache[id];
    }
    try {
      final response = await _dio.get('/service-categories/$id');
      final category = ServiceCategoryModel.fromJson(response.data);
      _categoryCache[id] = category;
      return category;
    } catch (_) {
      return null;
    }
  }

  /// 7. POST /repair-orders/{orderId}/confirm-completion
  Future<void> confirmOrderCompletion(int orderId) async {
    await _dio.post('/repair-orders/$orderId/confirm-completion');
  }

  /// 6. GET /service-categories/{categoryId}/device-types
  Future<List<DeviceTypeModel>> getDeviceTypesByCategory(int categoryId) async {
    if (_deviceTypesCache.containsKey(categoryId)) {
      return _deviceTypesCache[categoryId]!;
    }
    try {
      final response = await _dio.get(
        '/service-categories/$categoryId/device-types',
      );
      final List<dynamic> list = response.data is List ? response.data : [];
      final devices = list.map((e) => DeviceTypeModel.fromJson(e)).toList();
      _deviceTypesCache[categoryId] = devices;
      return devices;
    } catch (_) {
      return [];
    }
  }

  /// Hàm xử lý map thông tin Dịch vụ, Thiết bị & Báo giá của KTV được chọn
  Future<RepairOrderModel> _enrichOrder(RepairOrderModel order) async {
    // Gọi song song API lấy category và danh sách device-types
    final results = await Future.wait([
      getServiceCategoryById(order.categoryId),
      getDeviceTypesByCategory(order.categoryId),
    ]);

    final category = results[0] as ServiceCategoryModel?;
    final devices = results[1] as List<DeviceTypeModel>;

    DeviceTypeModel? matchedDevice;
    for (final d in devices) {
      if (d.id == order.deviceTypeId) {
        matchedDevice = d;
        break;
      }
    }

    // Nếu technician_id != null -> gọi API quotes và tìm quote trùng technician_id
    QuoteModel? matchedQuote;
    if (order.technicianId != null) {
      try {
        final quotes = await getOrderQuotes(order.id);
        for (final q in quotes) {
          if (q.technicianId == order.technicianId) {
            // Lấy thêm chi tiết quote nếu cần đầy đủ voucher/items/responded_at
            matchedQuote = await getQuoteDetail(order.id, q.quoteId);
            break;
          }
        }
      } catch (_) {}
    }

    return order.copyWith(
      categoryName: category?.name,
      deviceTypeName: matchedDevice?.name,
      deviceIconUrl: matchedDevice?.iconUrl ?? category?.iconUrl,
      matchedQuote: matchedQuote,
    );
  }
}
