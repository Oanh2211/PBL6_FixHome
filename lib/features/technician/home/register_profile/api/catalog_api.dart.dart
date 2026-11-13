import 'package:dio/dio.dart';
import 'package:fixhome/common/network/dio_client.dart';

import '../models/catalog_model.dart';

class CatalogApi {
  final Dio _dio;

  CatalogApi({Dio? dio}) : _dio = dio ?? DioClient.instance;
  Future<List<CatalogCategory>> getAllCategory() async {
    try {
      final response = await _dio.get('/service-categories');

      final data = response.data;

      if (data is! List) {
        throw Exception('Dữ liệu ngành nghề không hợp lệ');
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(CatalogCategory.fromJson)
          .where((category) => category.isActive)
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Không thể tải thông tin ngành nghề',
      );
    }
  }

  Future<List<CatalogCategory>> getCategories({String query = ''}) async {
    try {
      final response = await _dio.get(
        '/catalog/search',
        queryParameters: {'q': query},
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Dữ liệu danh mục không hợp lệ');
      }

      final categoriesJson = data['categories'] as List? ?? [];

      return categoriesJson
          .whereType<Map<String, dynamic>>()
          .map(CatalogCategory.fromJson)
          .where((category) => category.isActive)
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Không thể tải danh sách ngành nghề',
      );
    }
  }

  // GET /service-categories/{categoryId}
  // Lấy thông tin chi tiết ngành nghề
  Future<CatalogCategory> getCategoryDetail(int categoryId) async {
    try {
      final response = await _dio.get('/service-categories/$categoryId');

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Dữ liệu ngành nghề không hợp lệ');
      }

      return CatalogCategory.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Không thể tải thông tin ngành nghề',
      );
    }
  }

  // GET /service-categories/{categoryId}/device-types
  // Lấy danh sách thiết bị thuộc ngành nghề
  Future<List<CatalogDeviceType>> getDeviceTypes({
    required int categoryId,
    String query = '',
  }) async {
    try {
      final response = await _dio.get(
        '/service-categories/$categoryId/device-types',
        queryParameters: {if (query.isNotEmpty) 'q': query},
      );

      final data = response.data;

      if (data is! List) {
        throw Exception('Dữ liệu thiết bị không hợp lệ');
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(CatalogDeviceType.fromJson)
          .where((device) => device.isActive)
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Không thể tải danh sách thiết bị',
      );
    }
  }
}
