import 'package:dio/dio.dart';
import 'package:fixhome/common/network/dio_client.dart';

import '../model/technician_location_model.dart';
import '../model/technician_availability_model.dart';

class TechnicianAvailabilityApi {
  final Dio _dio = DioClient.instance;

  // API 1: Cập nhật vị trí hoạt động
  Future<void> updateMatchingLocation(TechnicianLocationModel model) async {
    await _dio.patch(
      '/technician/profile/matching-location',
      data: model.toJson(),
    );
  }

  // API 2: Bật / tắt trạng thái nhận việc
  Future<void> updateAvailability(TechnicianAvailabilityModel model) async {
    await _dio.patch('/technician/profile/availability', data: model.toJson());
  }
}
