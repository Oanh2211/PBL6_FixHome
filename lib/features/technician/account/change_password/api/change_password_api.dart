import 'package:dio/dio.dart';
import 'package:fixhome/common/network/dio_client.dart';
import 'package:fixhome/features/customer/account/change_password/model/change_password_request.dart';

class ChangePasswordApi {
  final Dio _dio;

  ChangePasswordApi({Dio? dio}) : _dio = dio ?? DioClient.instance;

  Future<void> changePassword(ChangePasswordRequest request) async {
    await _dio.patch('/me/password', data: request.toJson());
  }
}
