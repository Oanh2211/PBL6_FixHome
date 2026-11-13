import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fixhome/common/network/dio_client.dart';

import '../models/service_category_model.dart';
import '../models/device_type_model.dart';
import '../models/media_upload_model.dart';

class TechnicianRegisterSpecialtyApi {
  final Dio dio;

  TechnicianRegisterSpecialtyApi({Dio? dio}) : dio = dio ?? DioClient.instance;

  // ==============================
  // HELPER
  // ==============================

  List<dynamic> _extractList(dynamic data, String key) {
    if (data is List) return data;

    if (data is Map<String, dynamic>) {
      if (data[key] is List) return data[key];

      if (data['data'] is List) return data['data'];

      if (data['data'] is Map<String, dynamic>) {
        final nested = data['data'];
        if (nested[key] is List) return nested[key];
      }
    }

    return [];
  }

  // ==============================
  // 1. SEARCH CATALOG
  // GET /catalog/search?q=
  // ==============================

  Future<Map<String, dynamic>> searchCatalog(String query) async {
    final response = await dio.get(
      '/catalog/search',
      queryParameters: {'q': query},
    );

    final data = response.data;

    if (data is! Map<String, dynamic>) {
      return {
        'categories': <ServiceCategoryModel>[],
        'device_types': <DeviceTypeModel>[],
      };
    }

    final categories = _extractList(data, 'categories')
        .map((e) => ServiceCategoryModel.fromJson(e))
        .where((e) => e.isActive)
        .toList();

    final devices = _extractList(
      data,
      'device_types',
    ).map((e) => DeviceTypeModel.fromJson(e)).where((e) => e.isActive).toList();

    return {'categories': categories, 'device_types': devices};
  }

  // ==============================
  // 2. GET SERVICE CATEGORIES
  // GET /service-categories?q=
  // ==============================

  Future<List<ServiceCategoryModel>> getCategories({String query = ''}) async {
    final response = await dio.get(
      '/service-categories',
      queryParameters: {if (query.isNotEmpty) 'q': query},
    );

    return _extractList(response.data, 'categories')
        .map((e) => ServiceCategoryModel.fromJson(e))
        .where((e) => e.isActive)
        .toList();
  }

  // ==============================
  // 3. GET DEVICE TYPES
  // GET /service-categories/{categoryId}/device-types?q=
  // ==============================

  Future<List<DeviceTypeModel>> getDeviceTypes({
    required int categoryId,
    String query = '',
  }) async {
    final response = await dio.get(
      '/service-categories/$categoryId/device-types',
      queryParameters: {if (query.isNotEmpty) 'q': query},
    );

    return _extractList(
      response.data,
      'device_types',
    ).map((e) => DeviceTypeModel.fromJson(e)).where((e) => e.isActive).toList();
  }

  // ==============================
  // 4. CREATE MEDIA UPLOAD INTENT
  // POST /media/upload-intents
  // ==============================

  Future<MediaUploadIntentModel> createUploadIntent() async {
    final response = await dio.post(
      '/media/upload-intents',
      data: {'media_type': 'IMAGE'},
    );

    return MediaUploadIntentModel.fromJson(response.data);
  }

  // ==============================
  // 5. UPLOAD IMAGE TO CLOUDINARY
  // ==============================

  Future<String> uploadImageToCloudinary({
    required File file,
    required MediaUploadIntentModel intent,
  }) async {
    final cloudinaryDio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
      ),
    );

    final formData = FormData.fromMap({
      ...intent.uploadParams,
      'api_key': intent.apiKey,
      'signature': intent.signature,
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split(Platform.pathSeparator).last,
      ),
    });

    final response = await cloudinaryDio.post(
      intent.uploadUrl,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final data = response.data;

    final fileUrl = data['secure_url'] ?? data['url'];

    if (fileUrl == null || fileUrl.toString().isEmpty) {
      throw Exception('Cloudinary không trả về URL ảnh');
    }

    return fileUrl.toString();
  }

  // ==============================
  // 6. COMPLETE MEDIA UPLOAD
  // POST /media/upload-intents/{id}/complete
  // Không có request body
  // ==============================

  Future<MediaUploadResultModel> completeUpload({
    required String uploadIntentId,
  }) async {
    final response = await dio.post(
      '/media/upload-intents/$uploadIntentId/complete',
    );

    return MediaUploadResultModel.fromJson(response.data);
  }

  // ==============================
  // 7. REGISTER TECHNICIAN SPECIALTY
  // POST /technician/specialties
  // ==============================

  Future<void> registerSpecialty({
    required int categoryId,
    required String experienceLevel,
    required bool acceptAllDevices,
    required List<int> deviceTypeIds,
    required List<String> evidenceUrls,
  }) async {
    await dio.post(
      '/technician/specialties',
      data: {
        'category_id': categoryId,
        'experience_level': experienceLevel,
        'accept_all_devices': acceptAllDevices,
        'device_type_ids': deviceTypeIds,
        'evidence_urls': evidenceUrls,
      },
    );
  }
}
