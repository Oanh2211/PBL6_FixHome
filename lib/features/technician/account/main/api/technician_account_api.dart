import 'package:dio/dio.dart';
import 'package:fixhome/common/network/dio_client.dart';
import 'package:fixhome/features/customer/account/main/model/logout_request_model.dart';
import 'package:fixhome/features/technician/account/main/model/technician_account_model.dart';

class TechnicianAccountApi {
  final Dio _dio;

  TechnicianAccountApi({Dio? dio}) : _dio = dio ?? DioClient.instance;

  // Chuẩn hóa response có hoặc không có data
  Map<String, dynamic> _extractData(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];

      if (data is Map<String, dynamic>) {
        return data;
      }

      return response;
    }

    throw Exception('Invalid API response');
  }

  Future<TechnicianAccountModel> getAccount() async {
    try {
      final results = await Future.wait([
        _dio.get('/technician/profile'),
        _dio.get('/me'),
      ]);

      final profileJson = _extractData(results[0].data);
      final meJson = _extractData(results[1].data);

      return TechnicianAccountModel.fromJson(
        profileJson: profileJson,
        meJson: meJson,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Unable to load account information',
      );
    }
  }

  Future<void> logout({required String refreshToken}) async {
    try {
      final response = await _dio.post(
        '/auth/logout',
        data: LogoutRequestModel(refreshToken: refreshToken).toJson(),
      );

      print('Logout thành công: ${response.statusCode}');
    } on DioException catch (e) {
      print('--- LỖI ĐĂNG XUẤT ---');
      print('Status code: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
      print('Message error: ${e.message}');

      rethrow;
    }
  }
}
