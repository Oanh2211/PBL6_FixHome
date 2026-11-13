import 'package:dio/dio.dart';
import '../model/device_type_model.dart';

class DeviceTypeApi {
  final Dio dio;

  DeviceTypeApi({required this.dio});

  Future<List<DeviceTypeModel>> getDeviceTypes({
    required int categoryId,
    String? query,
  }) async {
    try {
      final response = await dio.get(
        '/service-categories/$categoryId/device-types',
        queryParameters: {
          if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        },
      );

      final dynamic responseData = response.data;

      dynamic listData = responseData;

      if (responseData is Map<String, dynamic>) {
        listData =
            responseData['data'] ??
            responseData['items'] ??
            responseData['result'] ??
            [];
      }

      if (listData is! List) {
        throw Exception('Invalid device type response');
      }

      return listData
          .whereType<Map<String, dynamic>>()
          .map((json) => DeviceTypeModel.fromJson(json))
          .where((device) => device.isActive)
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            e.message ??
            'Unable to load device types',
      );
    }
  }
}
