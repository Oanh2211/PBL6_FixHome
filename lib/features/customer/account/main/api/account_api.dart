import 'package:dio/dio.dart';
import 'package:fixhome/common/network/dio_client.dart';
import 'package:fixhome/features/customer/account/main/model/logout_request_model.dart';

class AccountApi {
  final Dio dio;

  AccountApi({Dio? dio}) : dio = dio ?? DioClient.instance;

  Future<void> logout({required String refreshToken}) async {
    try {
      final response = await dio.post(
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
