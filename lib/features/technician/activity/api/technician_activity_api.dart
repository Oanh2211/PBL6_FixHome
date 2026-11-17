import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fixhome/common/network/dio_client.dart';
import '../model/technician_order_model.dart';

class _CatalogMeta {
  final String name;
  final String iconUrl;
  const _CatalogMeta({required this.name, this.iconUrl = ''});
}

class TechnicianActivityApi {
  final Dio _dio = DioClient.instance;

  /// Cache map categoryId & deviceTypeId -> {name, iconUrl}
  final Map<int, _CatalogMeta> _categoryCache = {};
  final Map<int, _CatalogMeta> _deviceCache = {};

  /// Lấy danh sách Category và map vào cache (bao gồm icon_url)
  Future<void> _ensureCategoriesLoaded() async {
    if (_categoryCache.isNotEmpty) return;
    try {
      final response = await _dio.get('/service-categories');
      final data = response.data;
      final List<dynamic> list = data is List
          ? data
          : (data['content'] ?? data['data'] ?? []);
      for (final item in list) {
        final id = (item['id'] as num?)?.toInt();
        final name = item['name']?.toString() ?? '';
        final iconUrl = item['icon_url']?.toString() ?? '';
        if (id != null && name.isNotEmpty) {
          _categoryCache[id] = _CatalogMeta(name: name, iconUrl: iconUrl);
        }
      }
    } catch (_) {}
  }

  /// Lấy danh sách Device theo categoryId và map vào cache (bao gồm icon_url)
  Future<void> _ensureDevicesLoaded(int categoryId) async {
    if (categoryId == 0) return;
    try {
      final response = await _dio.get(
        '/service-categories/$categoryId/device-types',
      );
      final data = response.data;
      final List<dynamic> list = data is List
          ? data
          : (data['content'] ?? data['data'] ?? []);

      for (final item in list) {
        final id = (item['id'] as num?)?.toInt();
        final name = item['name']?.toString() ?? '';
        final iconUrl = item['icon_url']?.toString() ?? '';
        if (id != null && name.isNotEmpty) {
          _deviceCache[id] = _CatalogMeta(name: name, iconUrl: iconUrl);
        }
      }
    } catch (e) {
      print('Lỗi lấy Device Type của Category $categoryId: $e');
    }
  }

  /// Helper lấy iconUrl ưu tiên từ Device, nếu rỗng thì lấy từ Category
  String _resolveIconUrl(int catId, int devId) {
    final devIcon = _deviceCache[devId]?.iconUrl ?? '';
    if (devIcon.isNotEmpty) return devIcon;
    return _categoryCache[catId]?.iconUrl ?? '';
  }

  /// 1. GET /technician/repair-orders
  Future<List<TechnicianOrderModel>> getAssignedOrders({
    required String scope,
    int page = 1,
    int pageSize = 20,
  }) async {
    await _ensureCategoriesLoaded();

    final response = await _dio.get(
      '/technician/repair-orders',
      queryParameters: {'scope': scope, 'page': page, 'page_size': pageSize},
    );

    final List<dynamic> content = response.data['content'] ?? [];

    final categoryIds = content
        .map((e) => (e['category_id'] as num?)?.toInt() ?? 0)
        .where((id) => id != 0)
        .toSet();
    await Future.wait(categoryIds.map(_ensureDevicesLoaded));

    return content.map((json) {
      final map = json as Map<String, dynamic>;
      final catId = (map['category_id'] as num?)?.toInt() ?? 0;
      final devId = (map['device_type_id'] as num?)?.toInt() ?? 0;
      return TechnicianOrderModel.fromJson(
        map,
        categoryName: _categoryCache[catId]?.name ?? 'Dịch vụ sửa chữa',
        deviceName: _deviceCache[devId]?.name ?? 'Thiết bị gia dụng',
        deviceIconUrl: _resolveIconUrl(catId, devId),
      );
    }).toList();
  }

  /// 2. GET /technician/repair-orders/{orderId}
  Future<TechnicianOrderModel> getOrderDetail(int orderId) async {
    await _ensureCategoriesLoaded();
    final response = await _dio.get('/technician/repair-orders/$orderId');
    final map = response.data as Map<String, dynamic>;
    final catId = (map['category_id'] as num?)?.toInt() ?? 0;
    final devId = (map['device_type_id'] as num?)?.toInt() ?? 0;

    if (!_deviceCache.containsKey(devId)) {
      await _ensureDevicesLoaded(catId);
    }

    return TechnicianOrderModel.fromJson(
      map,
      categoryName: _categoryCache[catId]?.name ?? 'Dịch vụ sửa chữa',
      deviceName: _deviceCache[devId]?.name ?? 'Thiết bị gia dụng',
      deviceIconUrl: _resolveIconUrl(catId, devId),
    );
  }

  Future<TechnicianOrderModel> startTravelling(int orderId) async {
    final response = await _dio.post(
      '/technician/repair-orders/$orderId/start-travelling',
    );
    return _parseOrderWithCache(response.data);
  }

  /// 4. POST /technician/repair-orders/{orderId}/arrive
  Future<TechnicianOrderModel> arriveAtLocation(int orderId) async {
    final response = await _dio.post(
      '/technician/repair-orders/$orderId/arrive',
    );
    return _parseOrderWithCache(response.data);
  }

  /// 5. POST /technician/repair-orders/{orderId}/start-repair
  Future<TechnicianOrderModel> startRepair(int orderId) async {
    final response = await _dio.post(
      '/technician/repair-orders/$orderId/start-repair',
    );
    return _parseOrderWithCache(response.data);
  }

  /// 6. PUT /technician/repair-orders/{orderId}/quote (Gửi chốt giá sau kiểm tra)
  Future<void> submitFinalQuote(
    int orderId,
    FinalQuoteRequestModel request,
  ) async {
    await _dio.put(
      '/technician/repair-orders/$orderId/quote',
      data: request.toJson(),
    );
  }

  /// MỚI: Upload 1 file (IMAGE hoặc VIDEO) qua 2 API /media/upload-intents và trả về media_id
  Future<int> uploadMediaFile(File file, {String mediaType = 'IMAGE'}) async {
    // Bước 1: Tạo phiên upload (POST /media/upload-intents)
    final intentRes = await _dio.post(
      '/media/upload-intents',
      data: {'media_type': mediaType},
    );
    final intentData = intentRes.data as Map<String, dynamic>;
    final String intentId = intentData['upload_intent_id'].toString();
    final String uploadUrl = intentData['upload_url'].toString();
    final String apiKey = intentData['api_key']?.toString() ?? '';
    final String signature = intentData['signature']?.toString() ?? '';
    final Map<String, dynamic> uploadParams =
        (intentData['upload_params'] as Map<String, dynamic>?) ?? {};

    // Bước 2: Upload trực tiếp file lên Cloudinary (dùng Dio riêng để tránh gắn Bearer token của backend)
    final formMap = <String, dynamic>{
      ...uploadParams,
      if (apiKey.isNotEmpty) 'api_key': apiKey,
      if (signature.isNotEmpty) 'signature': signature,
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    };

    final cloudinaryDio = Dio();
    await cloudinaryDio.post(uploadUrl, data: FormData.fromMap(formMap));

    // Bước 3: Xác nhận hoàn tất upload với Backend để lấy media_id (POST /media/upload-intents/{id}/complete)
    final completeRes = await _dio.post(
      '/media/upload-intents/$intentId/complete',
    );
    final completeData = completeRes.data as Map<String, dynamic>;
    final int mediaId = (completeData['media_id'] as num).toInt();

    return mediaId;
  }

  /// 7. POST /technician/repair-orders/{orderId}/complete (Tự động upload list file nếu truyền vào)
  Future<TechnicianOrderModel> completeOrder(
    int orderId, {
    required double finalAmount,
    required String workPerformed,
    String completionNote = '',
    int warrantyDurationDays = 30,
    List<int> mediaIds = const [],
    List<File> evidenceFiles =
        const [], // MỚI: Truyền danh sách ảnh/video thực tế
  }) async {
    final List<int> allMediaIds = [...mediaIds];

    // Upload song song các file bằng chứng nghiệm thu để lấy media_id
    if (evidenceFiles.isNotEmpty) {
      final uploadedIds = await Future.wait(
        evidenceFiles.map((file) {
          final ext = file.path.split('.').last.toLowerCase();
          final isVideo = ['mp4', 'mov', 'avi', 'mkv'].contains(ext);
          return uploadMediaFile(file, mediaType: isVideo ? 'VIDEO' : 'IMAGE');
        }),
      );
      allMediaIds.addAll(uploadedIds);
    }

    final response = await _dio.post(
      '/technician/repair-orders/$orderId/complete',
      data: {
        'final_amount': finalAmount,
        'work_performed': workPerformed,
        'completion_note': completionNote,
        'warranty_duration_days': warrantyDurationDays,
        'media_ids': allMediaIds,
      },
    );
    return _parseOrderWithCache(response.data);
  }

  TechnicianOrderModel _parseOrderWithCache(dynamic data) {
    final map = data as Map<String, dynamic>;
    final catId = (map['category_id'] as num?)?.toInt() ?? 0;
    final devId = (map['device_type_id'] as num?)?.toInt() ?? 0;
    return TechnicianOrderModel.fromJson(
      map,
      categoryName: _categoryCache[catId]?.name ?? 'Dịch vụ sửa chữa',
      deviceName: _deviceCache[devId]?.name ?? 'Thiết bị gia dụng',
      deviceIconUrl: _resolveIconUrl(catId, devId),
    );
  }
}
