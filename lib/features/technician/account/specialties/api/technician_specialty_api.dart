import 'package:fixhome/common/network/dio_client.dart';
import 'package:fixhome/features/technician/account/specialties/models/technician_specialty_model.dart';

class TechnicianSpecialtyApi {
  final _dio = DioClient.instance;

  // GET: Danh sách nghiệp vụ
  Future<List<TechnicianSpecialtyModel>> getSpecialties() async {
    try {
      final response = await _dio.get('/technician/specialties');

      final data = response.data;

      final List<dynamic> list = data is List ? data : data['data'] ?? [];

      return list
          .map(
            (e) =>
                TechnicianSpecialtyModel.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // GET: Chi tiết nghiệp vụ
  Future<TechnicianSpecialtyModel> getSpecialtyDetail(int id) async {
    try {
      final response = await _dio.get('/technician/specialties/$id');

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return TechnicianSpecialtyModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      rethrow;
    }
  }

  // POST: Đăng ký nghiệp vụ
  Future<TechnicianSpecialtyModel> createSpecialty(
    CreateTechnicianSpecialtyRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/technician/specialties',
        data: request.toJson(),
      );

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return TechnicianSpecialtyModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      rethrow;
    }
  }

  // PATCH: Cập nhật chuyên môn
  Future<void> updateSpecialty(
    int id,
    UpdateTechnicianSpecialtyRequest request,
  ) async {
    await _dio.patch('/technician/specialties/$id', data: request.toJson());
  }

  // DELETE: Xóa chuyên môn
  Future<void> deleteSpecialty(int id) async {
    await _dio.delete('/technician/specialties/$id');
  }
}
