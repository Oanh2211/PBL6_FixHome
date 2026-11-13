import 'package:dio/dio.dart';
import 'package:fixhome/common/network/dio_client.dart';
import 'package:fixhome/features/technician/account/specialties/models/device_type_model.dart';

class DeviceTypeApi {
  final Dio dio;

  DeviceTypeApi({Dio? dio}) : dio = dio ?? DioClient.instance;

  Future<List<DeviceTypeModel>> getDeviceTypes({
    required int categoryId,
    String? query,
  }) async {
    try {
      final response = await dio.get(
        '/service-categories/$categoryId/device-types',
        queryParameters: {if (query != null && query.isNotEmpty) 'q': query},
      );

      final data = response.data;

      final List<dynamic> list = data is List
          ? data
          : data['data'] ?? data['items'] ?? data['result'] ?? [];

      return list
          .map((e) => DeviceTypeModel.fromJson(e))
          .where((e) => e.isActive)
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Không thể tải danh sách thiết bị',
      );
    }
  }
}
