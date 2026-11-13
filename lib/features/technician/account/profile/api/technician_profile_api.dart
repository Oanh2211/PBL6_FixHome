import 'package:dio/dio.dart';

import 'package:fixhome/common/network/dio_client.dart';
import 'package:fixhome/features/technician/account/profile/model/technician_profile_model.dart';

class TechnicianProfileApi {
  final Dio _dio;

  TechnicianProfileApi({Dio? dio}) : _dio = dio ?? DioClient.instance;

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

  // GET: Lấy hồ sơ kỹ thuật viên
  Future<TechnicianProfileModel> getProfile() async {
    try {
      final response = await _dio.get('/technician/profile');

      return TechnicianProfileModel.fromJson(_extractData(response.data));
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // PATCH: Cập nhật hồ sơ kỹ thuật viên
  Future<TechnicianProfileModel> updateProfile(
    TechnicianProfileModel profile,
  ) async {
    try {
      final response = await _dio.patch(
        '/technician/profile',
        data: profile.toUpdateJson(),
      );

      return TechnicianProfileModel.fromJson(_extractData(response.data));
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  String _getErrorMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map) {
      return data['message']?.toString() ??
          data['detail']?.toString() ??
          'Request failed';
    }

    return e.message ?? 'Something went wrong';
  }
}
