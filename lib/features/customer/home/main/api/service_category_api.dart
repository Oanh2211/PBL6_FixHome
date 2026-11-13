import 'package:dio/dio.dart';
import 'package:fixhome/common/network/dio_client.dart';
import 'package:fixhome/features/customer/home/main/model/service_category_model.dart';
import 'package:fixhome/features/customer/home/main/model/catalog_search_model.dart';

class ServiceCategoryApi {
  final Dio _dio;

  ServiceCategoryApi({Dio? dio}) : _dio = dio ?? DioClient.instance;

  // GET: /service-categories
  Future<List<ServiceCategoryModel>> getCategories({String? query}) async {
    try {
      final response = await _dio.get(
        '/service-categories',
        queryParameters: {
          if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        },
      );

      final List<dynamic> data = response.data as List;

      return data
          .map(
            (item) =>
                ServiceCategoryModel.fromJson(item as Map<String, dynamic>),
          )
          .where((category) => category.isActive)
          .toList();
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']
          : null;

      throw Exception(message ?? 'Không thể tải danh mục dịch vụ');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }

  // GET: /catalog/search?q=...
  Future<CatalogSearchModel> searchCatalog({required String query}) async {
    try {
      final response = await _dio.get(
        '/catalog/search',
        queryParameters: {'q': query.trim()},
      );

      final data = response.data as Map<String, dynamic>;

      return CatalogSearchModel.fromJson(data);
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']
          : null;

      throw Exception(message ?? 'Không thể tìm kiếm danh mục');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }
}
