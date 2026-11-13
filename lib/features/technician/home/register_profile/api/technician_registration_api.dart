import 'package:dio/dio.dart';
import 'package:fixhome/common/network/dio_client.dart';

import '../models/technician_profile_request.dart';
import '../models/technician_specialty_request.dart';

class TechnicianRegistrationApi {
  final Dio dio;

  TechnicianRegistrationApi({Dio? dio}) : dio = dio ?? DioClient.instance;

  // API 1: Cập nhật profile
  Future<void> updateProfile(TechnicianProfileRequest request) async {
    await dio.patch('/technician/profile', data: request.toJson());
  }

  // API 2: Lưu chuyên môn
  Future<void> saveSpecialties(TechnicianSpecialtyRequest request) async {
    await dio.post('/technician/specialties', data: request.toJson());
  }

  // API 3: Submit hồ sơ
  Future<void> submitProfile() async {
    await dio.post('/technician/profile/submit');
  }
}
