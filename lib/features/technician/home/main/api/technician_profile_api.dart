import 'package:dio/dio.dart';
import 'package:fixhome/common/network/dio_client.dart';
import 'package:fixhome/features/technician/home/main/model/me_model.dart';

import '../model/technician_profile_model.dart';

class TechnicianProfileApi {
  // Chuẩn hóa response từ backend
  Map<String, dynamic> _parseResponse(dynamic responseData) {
    if (responseData is! Map) {
      throw Exception('Dữ liệu trả về không hợp lệ');
    }

    final json = Map<String, dynamic>.from(responseData);

    // Hỗ trợ cả {data: {...}} và {...}
    final data = json['data'];

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return json;
  }

  String _getErrorMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    return e.message ?? 'Không thể kết nối đến máy chủ';
  }

  // GET /technician/profile
  Future<TechnicianProfileModel> getTechnicianProfile() async {
    try {
      final response = await DioClient.instance.get('/technician/profile');

      final data = _parseResponse(response.data);

      return TechnicianProfileModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // GET /me
  Future<MeModel> getMe() async {
    try {
      final response = await DioClient.instance.get('/me');

      final data = _parseResponse(response.data);

      return MeModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }
}
